import kopf
from kubernetes import client, config

GROUP = "otus.homework"
VERSION = "v1"
PLURAL = "mysqls"

@kopf.on.startup()
def startup(**kwargs):
    config.load_incluster_config()

@kopf.on.create(GROUP, VERSION, PLURAL)
def create_mysql(spec, name, namespace, **kwargs):
    image = spec["image"]
    database = spec["database"]
    password = spec["password"]
    storage_size = spec["storage_size"]

    core = client.CoreV1Api()
    apps = client.AppsV1Api()

    # ---------- PV ----------
    pv = client.V1PersistentVolume(
        metadata=client.V1ObjectMeta(name=f"{name}-pv"),
        spec=client.V1PersistentVolumeSpec(
            capacity={"storage": storage_size},
            access_modes=["ReadWriteOnce"],
            host_path=client.V1HostPathVolumeSource(path=f"/data/{name}"),
            persistent_volume_reclaim_policy="Delete"
        )
    )
    core.create_persistent_volume(pv)

    # ---------- PVC ----------
    pvc = client.V1PersistentVolumeClaim(
        metadata=client.V1ObjectMeta(name=f"{name}-pvc", namespace=namespace),
        spec=client.V1PersistentVolumeClaimSpec(
            access_modes=["ReadWriteOnce"],
            resources=client.V1ResourceRequirements(
                requests={"storage": storage_size}
            )
        )
    )
    core.create_namespaced_persistent_volume_claim(namespace, pvc)

    # ---------- Deployment ----------
    deployment = client.V1Deployment(
        metadata=client.V1ObjectMeta(name=name, namespace=namespace),
        spec=client.V1DeploymentSpec(
            replicas=1,
            selector=client.V1LabelSelector(
                match_labels={"app": name}
            ),
            template=client.V1PodTemplateSpec(
                metadata=client.V1ObjectMeta(labels={"app": name}),
                spec=client.V1PodSpec(
                    containers=[
                        client.V1Container(
                            name="mysql",
                            image=image,
                            env=[
                                client.V1EnvVar(name="MYSQL_DATABASE", value=database),
                                client.V1EnvVar(name="MYSQL_ROOT_PASSWORD", value=password)
                            ],
                            volume_mounts=[
                                client.V1VolumeMount(
                                    mount_path="/var/lib/mysql",
                                    name="mysql-storage"
                                )
                            ]
                        )
                    ],
                    volumes=[
                        client.V1Volume(
                            name="mysql-storage",
                            persistent_volume_claim=client.V1PersistentVolumeClaimVolumeSource(
                                claim_name=f"{name}-pvc"
                            )
                        )
                    ]
                )
            )
        )
    )
    apps.create_namespaced_deployment(namespace, deployment)

    # ---------- Service ----------
    service = client.V1Service(
        metadata=client.V1ObjectMeta(name=name, namespace=namespace),
        spec=client.V1ServiceSpec(
            selector={"app": name},
            ports=[client.V1ServicePort(port=3306, target_port=3306)],
            type="ClusterIP"
        )
    )
    core.create_namespaced_service(namespace, service)

@kopf.on.delete(GROUP, VERSION, PLURAL)
def delete_mysql(name, namespace, **kwargs):
    core = client.CoreV1Api()
    apps = client.AppsV1Api()

    apps.delete_namespaced_deployment(name, namespace)
    core.delete_namespaced_service(name, namespace)
    core.delete_namespaced_persistent_volume_claim(f"{name}-pvc", namespace)
    core.delete_persistent_volume(f"{name}-pv")