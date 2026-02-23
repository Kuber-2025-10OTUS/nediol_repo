<details>
<summary>Вывод команды ls –la для директории /etc/nginx</summary>

```bash
ls -la /proc/1/root/etc/nginx
```

```
total 48
drwxr-xr-x    3 root     root          4096 Oct  5  2020 .
drwxr-xr-x    1 root     root          4096 Feb 23 09:24 ..
drwxr-xr-x    2 root     root          4096 Oct  5  2020 conf.d
-rw-r--r--    1 root     root          1007 Apr 21  2020 fastcgi_params
-rw-r--r--    1 root     root          2837 Apr 21  2020 koi-utf
-rw-r--r--    1 root     root          2223 Apr 21  2020 koi-win
-rw-r--r--    1 root     root          5231 Apr 21  2020 mime.types
lrwxrwxrwx    1 root     root            22 Apr 21  2020 modules -> /usr/lib/nginx/modules
-rw-r--r--    1 root     root           643 Apr 21  2020 nginx.conf
-rw-r--r--    1 root     root           636 Apr 21  2020 scgi_params
-rw-r--r--    1 root     root           664 Apr 21  2020 uwsgi_params
-rw-r--r--    1 root     root          3610 Apr 21  2020 win-utf
```
</details>


<details>
<summary>Результат работы tcpdump</summary>

```bash
tcpdump -nn -i any -e port 80
```

```
tcpdump: WARNING: any: That device doesn't support promiscuous mode
(Promiscuous mode not supported on the "any" device)
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on any, link-type LINUX_SLL2 (Linux cooked v2), snapshot length 262144 bytes
09:35:08.904255 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv6 (0x86dd), length 100: ::1.60978 > ::1.80: Flags [S], seq 1126069275, win 65476, options [mss 65476,sackOK,TS val 2979656380 ecr 0,nop,wscale 7], length 0
09:35:08.904263 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv6 (0x86dd), length 80: ::1.80 > ::1.60978: Flags [R.], seq 0, ack 1126069276, win 0, length 0
09:35:08.904335 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 80: 127.0.0.1.36114 > 127.0.0.1.80: Flags [S], seq 2438834822, win 65495, options [mss 65495,sackOK,TS val 720903118 ecr 0,nop,wscale 7], length 0
09:35:08.904344 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 80: 127.0.0.1.80 > 127.0.0.1.36114: Flags [S.], seq 2627440316, ack 2438834823, win 65483, options [mss 65495,sackOK,TS val 720903118 ecr 720903118,nop,wscale 7], length 0
09:35:08.904352 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 72: 127.0.0.1.36114 > 127.0.0.1.80: Flags [.], ack 1, win 512, options [nop,nop,TS val 720903118 ecr 720903118], length 0
09:35:08.904429 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 145: 127.0.0.1.36114 > 127.0.0.1.80: Flags [P.], seq 1:74, ack 1, win 512, options [nop,nop,TS val 720903118 ecr 720903118], length 73: HTTP: GET / HTTP/1.1
09:35:08.904434 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 72: 127.0.0.1.80 > 127.0.0.1.36114: Flags [.], ack 74, win 512, options [nop,nop,TS val 720903118 ecr 720903118], length 0
09:35:08.904933 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 310: 127.0.0.1.80 > 127.0.0.1.36114: Flags [P.], seq 1:239, ack 74, win 512, options [nop,nop,TS val 720903118 ecr 720903118], length 238: HTTP: HTTP/1.1 200 OK
09:35:08.904955 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 72: 127.0.0.1.36114 > 127.0.0.1.80: Flags [.], ack 239, win 511, options [nop,nop,TS val 720903118 ecr 720903118], length 0
09:35:08.905143 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 684: 127.0.0.1.80 > 127.0.0.1.36114: Flags [P.], seq 239:851, ack 74, win 512, options [nop,nop,TS val 720903119 ecr 720903118], length 612: HTTP
09:35:08.905170 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 72: 127.0.0.1.36114 > 127.0.0.1.80: Flags [.], ack 851, win 507, options [nop,nop,TS val 720903119 ecr 720903119], length 0
09:35:08.905262 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 72: 127.0.0.1.36114 > 127.0.0.1.80: Flags [F.], seq 74, ack 851, win 507, options [nop,nop,TS val 720903119 ecr 720903119], length 0
09:35:08.905346 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 72: 127.0.0.1.80 > 127.0.0.1.36114: Flags [F.], seq 851, ack 75, win 512, options [nop,nop,TS val 720903119 ecr 720903119], length 0
09:35:08.905365 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 72: 127.0.0.1.36114 > 127.0.0.1.80: Flags [.], ack 852, win 507, options [nop,nop,TS val 720903119 ecr 720903119], length 0
09:35:14.614905 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv6 (0x86dd), length 100: ::1.60986 > ::1.80: Flags [S], seq 2808950744, win 65476, options [mss 65476,sackOK,TS val 2979662090 ecr 0,nop,wscale 7], length 0
09:35:14.614913 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv6 (0x86dd), length 80: ::1.80 > ::1.60986: Flags [R.], seq 0, ack 2808950745, win 0, length 0
09:35:14.614958 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 80: 127.0.0.1.36118 > 127.0.0.1.80: Flags [S], seq 4031227711, win 65495, options [mss 65495,sackOK,TS val 720908828 ecr 0,nop,wscale 7], length 0
09:35:14.614966 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 80: 127.0.0.1.80 > 127.0.0.1.36118: Flags [S.], seq 53340668, ack 4031227712, win 65483, options [mss 65495,sackOK,TS val 720908828 ecr 720908828,nop,wscale 7], length 0
09:35:14.614973 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 72: 127.0.0.1.36118 > 127.0.0.1.80: Flags [.], ack 1, win 512, options [nop,nop,TS val 720908828 ecr 720908828], length 0
09:35:14.615024 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 145: 127.0.0.1.36118 > 127.0.0.1.80: Flags [P.], seq 1:74, ack 1, win 512, options [nop,nop,TS val 720908829 ecr 720908828], length 73: HTTP: GET / HTTP/1.1
09:35:14.615028 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 72: 127.0.0.1.80 > 127.0.0.1.36118: Flags [.], ack 74, win 512, options [nop,nop,TS val 720908829 ecr 720908829], length 0
09:35:14.615110 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 310: 127.0.0.1.80 > 127.0.0.1.36118: Flags [P.], seq 1:239, ack 74, win 512, options [nop,nop,TS val 720908829 ecr 720908829], length 238: HTTP: HTTP/1.1 200 OK
09:35:14.615133 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 72: 127.0.0.1.36118 > 127.0.0.1.80: Flags [.], ack 239, win 511, options [nop,nop,TS val 720908829 ecr 720908829], length 0
09:35:14.615149 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 684: 127.0.0.1.80 > 127.0.0.1.36118: Flags [P.], seq 239:851, ack 74, win 512, options [nop,nop,TS val 720908829 ecr 720908829], length 612: HTTP
09:35:14.615153 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 72: 127.0.0.1.36118 > 127.0.0.1.80: Flags [.], ack 851, win 507, options [nop,nop,TS val 720908829 ecr 720908829], length 0
09:35:14.615233 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 72: 127.0.0.1.36118 > 127.0.0.1.80: Flags [F.], seq 74, ack 851, win 507, options [nop,nop,TS val 720908829 ecr 720908829], length 0
09:35:14.615284 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 72: 127.0.0.1.80 > 127.0.0.1.36118: Flags [F.], seq 851, ack 75, win 512, options [nop,nop,TS val 720908829 ecr 720908829], length 0
09:35:14.615298 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 72: 127.0.0.1.36118 > 127.0.0.1.80: Flags [.], ack 852, win 507, options [nop,nop,TS val 720908829 ecr 720908829], length 0
```
</details>


<details>
<summary>Логи и команда их получения</summary>

```bash
ls -la /host/var/log/pods/default_nginx-distroless_6b4a66f4-e6aa-4427-9e34-c3851c9b1f9e/nginx-distroless
```
```bash
 minikube  ~  cat /host/var/lib/docker/containers/43af19708a2dbe93f40f52ccda16ed0e599019f27227e2862d35b642a0f5f229/43af19708a2dbe93f40f52ccda16ed0e599019f27227e2862d35b642a0f5f229-json.log
```
```
{"log":"127.0.0.1 - - [23/Feb/2026:17:35:08 +0800] \"GET / HTTP/1.1\" 200 612 \"-\" \"curl/8.18.0\" \"-\"\n","stream":"stdout","time":"2026-02-23T09:35:08.905419934Z"}
{"log":"127.0.0.1 - - [23/Feb/2026:17:35:14 +0800] \"GET / HTTP/1.1\" 200 612 \"-\" \"curl/8.18.0\" \"-\"\n","stream":"stdout","time":"2026-02-23T09:35:14.615373431Z"}
```
</details>

Задание со *

Для запуска strace необходимо использовать profile, который даёт необходимые capabilities. Например, sysadmin

Команда:

```bash
kubectl debug -it nginx-distroless \
  --image=nicolaka/netshoot \
  --target=nginx-distroless \
  --profile=sysadmin
```

<details>
<summary>Вывод команды strace</summary>

```bash
 nginx-distroless  ~  strace -p 1
```
```
strace: Process 1 attached
rt_sigsuspend([], 8
```
</details>