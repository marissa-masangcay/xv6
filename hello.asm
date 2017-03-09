
_hello:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "types.h" 
#include "stat.h" 
#include "user.h" 

int main(int argc, char **argv) 
{ 
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 10             	sub    $0x10,%esp
  printf(1, "Hello, World!\n"); 
   9:	c7 44 24 04 0b 08 00 	movl   $0x80b,0x4(%esp)
  10:	00 
  11:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  18:	e8 28 04 00 00       	call   445 <printf>
  printf(1, "getpid() = %d\n", getpid()); 
  1d:	e8 0e 03 00 00       	call   330 <getpid>
  22:	89 44 24 08          	mov    %eax,0x8(%esp)
  26:	c7 44 24 04 1a 08 00 	movl   $0x81a,0x4(%esp)
  2d:	00 
  2e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  35:	e8 0b 04 00 00       	call   445 <printf>
  printf(1, "mygetpid() = %d\n", mygetpid()); 
  3a:	e8 11 03 00 00       	call   350 <mygetpid>
  3f:	89 44 24 08          	mov    %eax,0x8(%esp)
  43:	c7 44 24 04 29 08 00 	movl   $0x829,0x4(%esp)
  4a:	00 
  4b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  52:	e8 ee 03 00 00       	call   445 <printf>
  exit(); 
  57:	e8 54 02 00 00       	call   2b0 <exit>

0000005c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  5c:	55                   	push   %ebp
  5d:	89 e5                	mov    %esp,%ebp
  5f:	57                   	push   %edi
  60:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  61:	8b 4d 08             	mov    0x8(%ebp),%ecx
  64:	8b 55 10             	mov    0x10(%ebp),%edx
  67:	8b 45 0c             	mov    0xc(%ebp),%eax
  6a:	89 cb                	mov    %ecx,%ebx
  6c:	89 df                	mov    %ebx,%edi
  6e:	89 d1                	mov    %edx,%ecx
  70:	fc                   	cld    
  71:	f3 aa                	rep stos %al,%es:(%edi)
  73:	89 ca                	mov    %ecx,%edx
  75:	89 fb                	mov    %edi,%ebx
  77:	89 5d 08             	mov    %ebx,0x8(%ebp)
  7a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  7d:	5b                   	pop    %ebx
  7e:	5f                   	pop    %edi
  7f:	5d                   	pop    %ebp
  80:	c3                   	ret    

00000081 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  81:	55                   	push   %ebp
  82:	89 e5                	mov    %esp,%ebp
  84:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  87:	8b 45 08             	mov    0x8(%ebp),%eax
  8a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  8d:	90                   	nop
  8e:	8b 45 08             	mov    0x8(%ebp),%eax
  91:	8d 50 01             	lea    0x1(%eax),%edx
  94:	89 55 08             	mov    %edx,0x8(%ebp)
  97:	8b 55 0c             	mov    0xc(%ebp),%edx
  9a:	8d 4a 01             	lea    0x1(%edx),%ecx
  9d:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  a0:	8a 12                	mov    (%edx),%dl
  a2:	88 10                	mov    %dl,(%eax)
  a4:	8a 00                	mov    (%eax),%al
  a6:	84 c0                	test   %al,%al
  a8:	75 e4                	jne    8e <strcpy+0xd>
    ;
  return os;
  aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  ad:	c9                   	leave  
  ae:	c3                   	ret    

000000af <strcmp>:

int
strcmp(const char *p, const char *q)
{
  af:	55                   	push   %ebp
  b0:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  b2:	eb 06                	jmp    ba <strcmp+0xb>
    p++, q++;
  b4:	ff 45 08             	incl   0x8(%ebp)
  b7:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  ba:	8b 45 08             	mov    0x8(%ebp),%eax
  bd:	8a 00                	mov    (%eax),%al
  bf:	84 c0                	test   %al,%al
  c1:	74 0e                	je     d1 <strcmp+0x22>
  c3:	8b 45 08             	mov    0x8(%ebp),%eax
  c6:	8a 10                	mov    (%eax),%dl
  c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  cb:	8a 00                	mov    (%eax),%al
  cd:	38 c2                	cmp    %al,%dl
  cf:	74 e3                	je     b4 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  d1:	8b 45 08             	mov    0x8(%ebp),%eax
  d4:	8a 00                	mov    (%eax),%al
  d6:	0f b6 d0             	movzbl %al,%edx
  d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  dc:	8a 00                	mov    (%eax),%al
  de:	0f b6 c0             	movzbl %al,%eax
  e1:	29 c2                	sub    %eax,%edx
  e3:	89 d0                	mov    %edx,%eax
}
  e5:	5d                   	pop    %ebp
  e6:	c3                   	ret    

000000e7 <strlen>:

uint
strlen(char *s)
{
  e7:	55                   	push   %ebp
  e8:	89 e5                	mov    %esp,%ebp
  ea:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
  ed:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  f4:	eb 03                	jmp    f9 <strlen+0x12>
  f6:	ff 45 fc             	incl   -0x4(%ebp)
  f9:	8b 55 fc             	mov    -0x4(%ebp),%edx
  fc:	8b 45 08             	mov    0x8(%ebp),%eax
  ff:	01 d0                	add    %edx,%eax
 101:	8a 00                	mov    (%eax),%al
 103:	84 c0                	test   %al,%al
 105:	75 ef                	jne    f6 <strlen+0xf>
    ;
  return n;
 107:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 10a:	c9                   	leave  
 10b:	c3                   	ret    

0000010c <memset>:

void*
memset(void *dst, int c, uint n)
{
 10c:	55                   	push   %ebp
 10d:	89 e5                	mov    %esp,%ebp
 10f:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 112:	8b 45 10             	mov    0x10(%ebp),%eax
 115:	89 44 24 08          	mov    %eax,0x8(%esp)
 119:	8b 45 0c             	mov    0xc(%ebp),%eax
 11c:	89 44 24 04          	mov    %eax,0x4(%esp)
 120:	8b 45 08             	mov    0x8(%ebp),%eax
 123:	89 04 24             	mov    %eax,(%esp)
 126:	e8 31 ff ff ff       	call   5c <stosb>
  return dst;
 12b:	8b 45 08             	mov    0x8(%ebp),%eax
}
 12e:	c9                   	leave  
 12f:	c3                   	ret    

00000130 <strchr>:

char*
strchr(const char *s, char c)
{
 130:	55                   	push   %ebp
 131:	89 e5                	mov    %esp,%ebp
 133:	83 ec 04             	sub    $0x4,%esp
 136:	8b 45 0c             	mov    0xc(%ebp),%eax
 139:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 13c:	eb 12                	jmp    150 <strchr+0x20>
    if(*s == c)
 13e:	8b 45 08             	mov    0x8(%ebp),%eax
 141:	8a 00                	mov    (%eax),%al
 143:	3a 45 fc             	cmp    -0x4(%ebp),%al
 146:	75 05                	jne    14d <strchr+0x1d>
      return (char*)s;
 148:	8b 45 08             	mov    0x8(%ebp),%eax
 14b:	eb 11                	jmp    15e <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 14d:	ff 45 08             	incl   0x8(%ebp)
 150:	8b 45 08             	mov    0x8(%ebp),%eax
 153:	8a 00                	mov    (%eax),%al
 155:	84 c0                	test   %al,%al
 157:	75 e5                	jne    13e <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 159:	b8 00 00 00 00       	mov    $0x0,%eax
}
 15e:	c9                   	leave  
 15f:	c3                   	ret    

00000160 <gets>:

char*
gets(char *buf, int max)
{
 160:	55                   	push   %ebp
 161:	89 e5                	mov    %esp,%ebp
 163:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 166:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 16d:	eb 49                	jmp    1b8 <gets+0x58>
    cc = read(0, &c, 1);
 16f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 176:	00 
 177:	8d 45 ef             	lea    -0x11(%ebp),%eax
 17a:	89 44 24 04          	mov    %eax,0x4(%esp)
 17e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 185:	e8 3e 01 00 00       	call   2c8 <read>
 18a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 18d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 191:	7f 02                	jg     195 <gets+0x35>
      break;
 193:	eb 2c                	jmp    1c1 <gets+0x61>
    buf[i++] = c;
 195:	8b 45 f4             	mov    -0xc(%ebp),%eax
 198:	8d 50 01             	lea    0x1(%eax),%edx
 19b:	89 55 f4             	mov    %edx,-0xc(%ebp)
 19e:	89 c2                	mov    %eax,%edx
 1a0:	8b 45 08             	mov    0x8(%ebp),%eax
 1a3:	01 c2                	add    %eax,%edx
 1a5:	8a 45 ef             	mov    -0x11(%ebp),%al
 1a8:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1aa:	8a 45 ef             	mov    -0x11(%ebp),%al
 1ad:	3c 0a                	cmp    $0xa,%al
 1af:	74 10                	je     1c1 <gets+0x61>
 1b1:	8a 45 ef             	mov    -0x11(%ebp),%al
 1b4:	3c 0d                	cmp    $0xd,%al
 1b6:	74 09                	je     1c1 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1bb:	40                   	inc    %eax
 1bc:	3b 45 0c             	cmp    0xc(%ebp),%eax
 1bf:	7c ae                	jl     16f <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 1c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1c4:	8b 45 08             	mov    0x8(%ebp),%eax
 1c7:	01 d0                	add    %edx,%eax
 1c9:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1cc:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1cf:	c9                   	leave  
 1d0:	c3                   	ret    

000001d1 <stat>:

int
stat(char *n, struct stat *st)
{
 1d1:	55                   	push   %ebp
 1d2:	89 e5                	mov    %esp,%ebp
 1d4:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1d7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 1de:	00 
 1df:	8b 45 08             	mov    0x8(%ebp),%eax
 1e2:	89 04 24             	mov    %eax,(%esp)
 1e5:	e8 06 01 00 00       	call   2f0 <open>
 1ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 1ed:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 1f1:	79 07                	jns    1fa <stat+0x29>
    return -1;
 1f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 1f8:	eb 23                	jmp    21d <stat+0x4c>
  r = fstat(fd, st);
 1fa:	8b 45 0c             	mov    0xc(%ebp),%eax
 1fd:	89 44 24 04          	mov    %eax,0x4(%esp)
 201:	8b 45 f4             	mov    -0xc(%ebp),%eax
 204:	89 04 24             	mov    %eax,(%esp)
 207:	e8 fc 00 00 00       	call   308 <fstat>
 20c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 20f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 212:	89 04 24             	mov    %eax,(%esp)
 215:	e8 be 00 00 00       	call   2d8 <close>
  return r;
 21a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 21d:	c9                   	leave  
 21e:	c3                   	ret    

0000021f <atoi>:

int
atoi(const char *s)
{
 21f:	55                   	push   %ebp
 220:	89 e5                	mov    %esp,%ebp
 222:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 225:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 22c:	eb 24                	jmp    252 <atoi+0x33>
    n = n*10 + *s++ - '0';
 22e:	8b 55 fc             	mov    -0x4(%ebp),%edx
 231:	89 d0                	mov    %edx,%eax
 233:	c1 e0 02             	shl    $0x2,%eax
 236:	01 d0                	add    %edx,%eax
 238:	01 c0                	add    %eax,%eax
 23a:	89 c1                	mov    %eax,%ecx
 23c:	8b 45 08             	mov    0x8(%ebp),%eax
 23f:	8d 50 01             	lea    0x1(%eax),%edx
 242:	89 55 08             	mov    %edx,0x8(%ebp)
 245:	8a 00                	mov    (%eax),%al
 247:	0f be c0             	movsbl %al,%eax
 24a:	01 c8                	add    %ecx,%eax
 24c:	83 e8 30             	sub    $0x30,%eax
 24f:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 252:	8b 45 08             	mov    0x8(%ebp),%eax
 255:	8a 00                	mov    (%eax),%al
 257:	3c 2f                	cmp    $0x2f,%al
 259:	7e 09                	jle    264 <atoi+0x45>
 25b:	8b 45 08             	mov    0x8(%ebp),%eax
 25e:	8a 00                	mov    (%eax),%al
 260:	3c 39                	cmp    $0x39,%al
 262:	7e ca                	jle    22e <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 264:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 267:	c9                   	leave  
 268:	c3                   	ret    

00000269 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 269:	55                   	push   %ebp
 26a:	89 e5                	mov    %esp,%ebp
 26c:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 26f:	8b 45 08             	mov    0x8(%ebp),%eax
 272:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 275:	8b 45 0c             	mov    0xc(%ebp),%eax
 278:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 27b:	eb 16                	jmp    293 <memmove+0x2a>
    *dst++ = *src++;
 27d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 280:	8d 50 01             	lea    0x1(%eax),%edx
 283:	89 55 fc             	mov    %edx,-0x4(%ebp)
 286:	8b 55 f8             	mov    -0x8(%ebp),%edx
 289:	8d 4a 01             	lea    0x1(%edx),%ecx
 28c:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 28f:	8a 12                	mov    (%edx),%dl
 291:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 293:	8b 45 10             	mov    0x10(%ebp),%eax
 296:	8d 50 ff             	lea    -0x1(%eax),%edx
 299:	89 55 10             	mov    %edx,0x10(%ebp)
 29c:	85 c0                	test   %eax,%eax
 29e:	7f dd                	jg     27d <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 2a0:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2a3:	c9                   	leave  
 2a4:	c3                   	ret    
 2a5:	90                   	nop
 2a6:	90                   	nop
 2a7:	90                   	nop

000002a8 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2a8:	b8 01 00 00 00       	mov    $0x1,%eax
 2ad:	cd 40                	int    $0x40
 2af:	c3                   	ret    

000002b0 <exit>:
SYSCALL(exit)
 2b0:	b8 02 00 00 00       	mov    $0x2,%eax
 2b5:	cd 40                	int    $0x40
 2b7:	c3                   	ret    

000002b8 <wait>:
SYSCALL(wait)
 2b8:	b8 03 00 00 00       	mov    $0x3,%eax
 2bd:	cd 40                	int    $0x40
 2bf:	c3                   	ret    

000002c0 <pipe>:
SYSCALL(pipe)
 2c0:	b8 04 00 00 00       	mov    $0x4,%eax
 2c5:	cd 40                	int    $0x40
 2c7:	c3                   	ret    

000002c8 <read>:
SYSCALL(read)
 2c8:	b8 05 00 00 00       	mov    $0x5,%eax
 2cd:	cd 40                	int    $0x40
 2cf:	c3                   	ret    

000002d0 <write>:
SYSCALL(write)
 2d0:	b8 10 00 00 00       	mov    $0x10,%eax
 2d5:	cd 40                	int    $0x40
 2d7:	c3                   	ret    

000002d8 <close>:
SYSCALL(close)
 2d8:	b8 15 00 00 00       	mov    $0x15,%eax
 2dd:	cd 40                	int    $0x40
 2df:	c3                   	ret    

000002e0 <kill>:
SYSCALL(kill)
 2e0:	b8 06 00 00 00       	mov    $0x6,%eax
 2e5:	cd 40                	int    $0x40
 2e7:	c3                   	ret    

000002e8 <exec>:
SYSCALL(exec)
 2e8:	b8 07 00 00 00       	mov    $0x7,%eax
 2ed:	cd 40                	int    $0x40
 2ef:	c3                   	ret    

000002f0 <open>:
SYSCALL(open)
 2f0:	b8 0f 00 00 00       	mov    $0xf,%eax
 2f5:	cd 40                	int    $0x40
 2f7:	c3                   	ret    

000002f8 <mknod>:
SYSCALL(mknod)
 2f8:	b8 11 00 00 00       	mov    $0x11,%eax
 2fd:	cd 40                	int    $0x40
 2ff:	c3                   	ret    

00000300 <unlink>:
SYSCALL(unlink)
 300:	b8 12 00 00 00       	mov    $0x12,%eax
 305:	cd 40                	int    $0x40
 307:	c3                   	ret    

00000308 <fstat>:
SYSCALL(fstat)
 308:	b8 08 00 00 00       	mov    $0x8,%eax
 30d:	cd 40                	int    $0x40
 30f:	c3                   	ret    

00000310 <link>:
SYSCALL(link)
 310:	b8 13 00 00 00       	mov    $0x13,%eax
 315:	cd 40                	int    $0x40
 317:	c3                   	ret    

00000318 <mkdir>:
SYSCALL(mkdir)
 318:	b8 14 00 00 00       	mov    $0x14,%eax
 31d:	cd 40                	int    $0x40
 31f:	c3                   	ret    

00000320 <chdir>:
SYSCALL(chdir)
 320:	b8 09 00 00 00       	mov    $0x9,%eax
 325:	cd 40                	int    $0x40
 327:	c3                   	ret    

00000328 <dup>:
SYSCALL(dup)
 328:	b8 0a 00 00 00       	mov    $0xa,%eax
 32d:	cd 40                	int    $0x40
 32f:	c3                   	ret    

00000330 <getpid>:
SYSCALL(getpid)
 330:	b8 0b 00 00 00       	mov    $0xb,%eax
 335:	cd 40                	int    $0x40
 337:	c3                   	ret    

00000338 <sbrk>:
SYSCALL(sbrk)
 338:	b8 0c 00 00 00       	mov    $0xc,%eax
 33d:	cd 40                	int    $0x40
 33f:	c3                   	ret    

00000340 <sleep>:
SYSCALL(sleep)
 340:	b8 0d 00 00 00       	mov    $0xd,%eax
 345:	cd 40                	int    $0x40
 347:	c3                   	ret    

00000348 <uptime>:
SYSCALL(uptime)
 348:	b8 0e 00 00 00       	mov    $0xe,%eax
 34d:	cd 40                	int    $0x40
 34f:	c3                   	ret    

00000350 <mygetpid>:
SYSCALL(mygetpid)
 350:	b8 16 00 00 00       	mov    $0x16,%eax
 355:	cd 40                	int    $0x40
 357:	c3                   	ret    

00000358 <halt>:
SYSCALL(halt)
 358:	b8 17 00 00 00       	mov    $0x17,%eax
 35d:	cd 40                	int    $0x40
 35f:	c3                   	ret    

00000360 <pipe_count>:
SYSCALL(pipe_count)
 360:	b8 18 00 00 00       	mov    $0x18,%eax
 365:	cd 40                	int    $0x40
 367:	c3                   	ret    

00000368 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 368:	55                   	push   %ebp
 369:	89 e5                	mov    %esp,%ebp
 36b:	83 ec 18             	sub    $0x18,%esp
 36e:	8b 45 0c             	mov    0xc(%ebp),%eax
 371:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 374:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 37b:	00 
 37c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 37f:	89 44 24 04          	mov    %eax,0x4(%esp)
 383:	8b 45 08             	mov    0x8(%ebp),%eax
 386:	89 04 24             	mov    %eax,(%esp)
 389:	e8 42 ff ff ff       	call   2d0 <write>
}
 38e:	c9                   	leave  
 38f:	c3                   	ret    

00000390 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 390:	55                   	push   %ebp
 391:	89 e5                	mov    %esp,%ebp
 393:	56                   	push   %esi
 394:	53                   	push   %ebx
 395:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 398:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 39f:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3a3:	74 17                	je     3bc <printint+0x2c>
 3a5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3a9:	79 11                	jns    3bc <printint+0x2c>
    neg = 1;
 3ab:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3b2:	8b 45 0c             	mov    0xc(%ebp),%eax
 3b5:	f7 d8                	neg    %eax
 3b7:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3ba:	eb 06                	jmp    3c2 <printint+0x32>
  } else {
    x = xx;
 3bc:	8b 45 0c             	mov    0xc(%ebp),%eax
 3bf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3c2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 3c9:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 3cc:	8d 41 01             	lea    0x1(%ecx),%eax
 3cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
 3d2:	8b 5d 10             	mov    0x10(%ebp),%ebx
 3d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3d8:	ba 00 00 00 00       	mov    $0x0,%edx
 3dd:	f7 f3                	div    %ebx
 3df:	89 d0                	mov    %edx,%eax
 3e1:	8a 80 88 0a 00 00    	mov    0xa88(%eax),%al
 3e7:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 3eb:	8b 75 10             	mov    0x10(%ebp),%esi
 3ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3f1:	ba 00 00 00 00       	mov    $0x0,%edx
 3f6:	f7 f6                	div    %esi
 3f8:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3fb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 3ff:	75 c8                	jne    3c9 <printint+0x39>
  if(neg)
 401:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 405:	74 10                	je     417 <printint+0x87>
    buf[i++] = '-';
 407:	8b 45 f4             	mov    -0xc(%ebp),%eax
 40a:	8d 50 01             	lea    0x1(%eax),%edx
 40d:	89 55 f4             	mov    %edx,-0xc(%ebp)
 410:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 415:	eb 1e                	jmp    435 <printint+0xa5>
 417:	eb 1c                	jmp    435 <printint+0xa5>
    putc(fd, buf[i]);
 419:	8d 55 dc             	lea    -0x24(%ebp),%edx
 41c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 41f:	01 d0                	add    %edx,%eax
 421:	8a 00                	mov    (%eax),%al
 423:	0f be c0             	movsbl %al,%eax
 426:	89 44 24 04          	mov    %eax,0x4(%esp)
 42a:	8b 45 08             	mov    0x8(%ebp),%eax
 42d:	89 04 24             	mov    %eax,(%esp)
 430:	e8 33 ff ff ff       	call   368 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 435:	ff 4d f4             	decl   -0xc(%ebp)
 438:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 43c:	79 db                	jns    419 <printint+0x89>
    putc(fd, buf[i]);
}
 43e:	83 c4 30             	add    $0x30,%esp
 441:	5b                   	pop    %ebx
 442:	5e                   	pop    %esi
 443:	5d                   	pop    %ebp
 444:	c3                   	ret    

00000445 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 445:	55                   	push   %ebp
 446:	89 e5                	mov    %esp,%ebp
 448:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 44b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 452:	8d 45 0c             	lea    0xc(%ebp),%eax
 455:	83 c0 04             	add    $0x4,%eax
 458:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 45b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 462:	e9 77 01 00 00       	jmp    5de <printf+0x199>
    c = fmt[i] & 0xff;
 467:	8b 55 0c             	mov    0xc(%ebp),%edx
 46a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 46d:	01 d0                	add    %edx,%eax
 46f:	8a 00                	mov    (%eax),%al
 471:	0f be c0             	movsbl %al,%eax
 474:	25 ff 00 00 00       	and    $0xff,%eax
 479:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 47c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 480:	75 2c                	jne    4ae <printf+0x69>
      if(c == '%'){
 482:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 486:	75 0c                	jne    494 <printf+0x4f>
        state = '%';
 488:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 48f:	e9 47 01 00 00       	jmp    5db <printf+0x196>
      } else {
        putc(fd, c);
 494:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 497:	0f be c0             	movsbl %al,%eax
 49a:	89 44 24 04          	mov    %eax,0x4(%esp)
 49e:	8b 45 08             	mov    0x8(%ebp),%eax
 4a1:	89 04 24             	mov    %eax,(%esp)
 4a4:	e8 bf fe ff ff       	call   368 <putc>
 4a9:	e9 2d 01 00 00       	jmp    5db <printf+0x196>
      }
    } else if(state == '%'){
 4ae:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4b2:	0f 85 23 01 00 00    	jne    5db <printf+0x196>
      if(c == 'd'){
 4b8:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4bc:	75 2d                	jne    4eb <printf+0xa6>
        printint(fd, *ap, 10, 1);
 4be:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4c1:	8b 00                	mov    (%eax),%eax
 4c3:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 4ca:	00 
 4cb:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 4d2:	00 
 4d3:	89 44 24 04          	mov    %eax,0x4(%esp)
 4d7:	8b 45 08             	mov    0x8(%ebp),%eax
 4da:	89 04 24             	mov    %eax,(%esp)
 4dd:	e8 ae fe ff ff       	call   390 <printint>
        ap++;
 4e2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4e6:	e9 e9 00 00 00       	jmp    5d4 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 4eb:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 4ef:	74 06                	je     4f7 <printf+0xb2>
 4f1:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 4f5:	75 2d                	jne    524 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 4f7:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4fa:	8b 00                	mov    (%eax),%eax
 4fc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 503:	00 
 504:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 50b:	00 
 50c:	89 44 24 04          	mov    %eax,0x4(%esp)
 510:	8b 45 08             	mov    0x8(%ebp),%eax
 513:	89 04 24             	mov    %eax,(%esp)
 516:	e8 75 fe ff ff       	call   390 <printint>
        ap++;
 51b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 51f:	e9 b0 00 00 00       	jmp    5d4 <printf+0x18f>
      } else if(c == 's'){
 524:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 528:	75 42                	jne    56c <printf+0x127>
        s = (char*)*ap;
 52a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 52d:	8b 00                	mov    (%eax),%eax
 52f:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 532:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 536:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 53a:	75 09                	jne    545 <printf+0x100>
          s = "(null)";
 53c:	c7 45 f4 3a 08 00 00 	movl   $0x83a,-0xc(%ebp)
        while(*s != 0){
 543:	eb 1c                	jmp    561 <printf+0x11c>
 545:	eb 1a                	jmp    561 <printf+0x11c>
          putc(fd, *s);
 547:	8b 45 f4             	mov    -0xc(%ebp),%eax
 54a:	8a 00                	mov    (%eax),%al
 54c:	0f be c0             	movsbl %al,%eax
 54f:	89 44 24 04          	mov    %eax,0x4(%esp)
 553:	8b 45 08             	mov    0x8(%ebp),%eax
 556:	89 04 24             	mov    %eax,(%esp)
 559:	e8 0a fe ff ff       	call   368 <putc>
          s++;
 55e:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 561:	8b 45 f4             	mov    -0xc(%ebp),%eax
 564:	8a 00                	mov    (%eax),%al
 566:	84 c0                	test   %al,%al
 568:	75 dd                	jne    547 <printf+0x102>
 56a:	eb 68                	jmp    5d4 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 56c:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 570:	75 1d                	jne    58f <printf+0x14a>
        putc(fd, *ap);
 572:	8b 45 e8             	mov    -0x18(%ebp),%eax
 575:	8b 00                	mov    (%eax),%eax
 577:	0f be c0             	movsbl %al,%eax
 57a:	89 44 24 04          	mov    %eax,0x4(%esp)
 57e:	8b 45 08             	mov    0x8(%ebp),%eax
 581:	89 04 24             	mov    %eax,(%esp)
 584:	e8 df fd ff ff       	call   368 <putc>
        ap++;
 589:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 58d:	eb 45                	jmp    5d4 <printf+0x18f>
      } else if(c == '%'){
 58f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 593:	75 17                	jne    5ac <printf+0x167>
        putc(fd, c);
 595:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 598:	0f be c0             	movsbl %al,%eax
 59b:	89 44 24 04          	mov    %eax,0x4(%esp)
 59f:	8b 45 08             	mov    0x8(%ebp),%eax
 5a2:	89 04 24             	mov    %eax,(%esp)
 5a5:	e8 be fd ff ff       	call   368 <putc>
 5aa:	eb 28                	jmp    5d4 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5ac:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 5b3:	00 
 5b4:	8b 45 08             	mov    0x8(%ebp),%eax
 5b7:	89 04 24             	mov    %eax,(%esp)
 5ba:	e8 a9 fd ff ff       	call   368 <putc>
        putc(fd, c);
 5bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5c2:	0f be c0             	movsbl %al,%eax
 5c5:	89 44 24 04          	mov    %eax,0x4(%esp)
 5c9:	8b 45 08             	mov    0x8(%ebp),%eax
 5cc:	89 04 24             	mov    %eax,(%esp)
 5cf:	e8 94 fd ff ff       	call   368 <putc>
      }
      state = 0;
 5d4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 5db:	ff 45 f0             	incl   -0x10(%ebp)
 5de:	8b 55 0c             	mov    0xc(%ebp),%edx
 5e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5e4:	01 d0                	add    %edx,%eax
 5e6:	8a 00                	mov    (%eax),%al
 5e8:	84 c0                	test   %al,%al
 5ea:	0f 85 77 fe ff ff    	jne    467 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 5f0:	c9                   	leave  
 5f1:	c3                   	ret    
 5f2:	90                   	nop
 5f3:	90                   	nop

000005f4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5f4:	55                   	push   %ebp
 5f5:	89 e5                	mov    %esp,%ebp
 5f7:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5fa:	8b 45 08             	mov    0x8(%ebp),%eax
 5fd:	83 e8 08             	sub    $0x8,%eax
 600:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 603:	a1 a4 0a 00 00       	mov    0xaa4,%eax
 608:	89 45 fc             	mov    %eax,-0x4(%ebp)
 60b:	eb 24                	jmp    631 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 60d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 610:	8b 00                	mov    (%eax),%eax
 612:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 615:	77 12                	ja     629 <free+0x35>
 617:	8b 45 f8             	mov    -0x8(%ebp),%eax
 61a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 61d:	77 24                	ja     643 <free+0x4f>
 61f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 622:	8b 00                	mov    (%eax),%eax
 624:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 627:	77 1a                	ja     643 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 629:	8b 45 fc             	mov    -0x4(%ebp),%eax
 62c:	8b 00                	mov    (%eax),%eax
 62e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 631:	8b 45 f8             	mov    -0x8(%ebp),%eax
 634:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 637:	76 d4                	jbe    60d <free+0x19>
 639:	8b 45 fc             	mov    -0x4(%ebp),%eax
 63c:	8b 00                	mov    (%eax),%eax
 63e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 641:	76 ca                	jbe    60d <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 643:	8b 45 f8             	mov    -0x8(%ebp),%eax
 646:	8b 40 04             	mov    0x4(%eax),%eax
 649:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 650:	8b 45 f8             	mov    -0x8(%ebp),%eax
 653:	01 c2                	add    %eax,%edx
 655:	8b 45 fc             	mov    -0x4(%ebp),%eax
 658:	8b 00                	mov    (%eax),%eax
 65a:	39 c2                	cmp    %eax,%edx
 65c:	75 24                	jne    682 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 65e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 661:	8b 50 04             	mov    0x4(%eax),%edx
 664:	8b 45 fc             	mov    -0x4(%ebp),%eax
 667:	8b 00                	mov    (%eax),%eax
 669:	8b 40 04             	mov    0x4(%eax),%eax
 66c:	01 c2                	add    %eax,%edx
 66e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 671:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 674:	8b 45 fc             	mov    -0x4(%ebp),%eax
 677:	8b 00                	mov    (%eax),%eax
 679:	8b 10                	mov    (%eax),%edx
 67b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 67e:	89 10                	mov    %edx,(%eax)
 680:	eb 0a                	jmp    68c <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 682:	8b 45 fc             	mov    -0x4(%ebp),%eax
 685:	8b 10                	mov    (%eax),%edx
 687:	8b 45 f8             	mov    -0x8(%ebp),%eax
 68a:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 68c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 68f:	8b 40 04             	mov    0x4(%eax),%eax
 692:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 699:	8b 45 fc             	mov    -0x4(%ebp),%eax
 69c:	01 d0                	add    %edx,%eax
 69e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6a1:	75 20                	jne    6c3 <free+0xcf>
    p->s.size += bp->s.size;
 6a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a6:	8b 50 04             	mov    0x4(%eax),%edx
 6a9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ac:	8b 40 04             	mov    0x4(%eax),%eax
 6af:	01 c2                	add    %eax,%edx
 6b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b4:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6b7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ba:	8b 10                	mov    (%eax),%edx
 6bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6bf:	89 10                	mov    %edx,(%eax)
 6c1:	eb 08                	jmp    6cb <free+0xd7>
  } else
    p->s.ptr = bp;
 6c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c6:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6c9:	89 10                	mov    %edx,(%eax)
  freep = p;
 6cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ce:	a3 a4 0a 00 00       	mov    %eax,0xaa4
}
 6d3:	c9                   	leave  
 6d4:	c3                   	ret    

000006d5 <morecore>:

static Header*
morecore(uint nu)
{
 6d5:	55                   	push   %ebp
 6d6:	89 e5                	mov    %esp,%ebp
 6d8:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 6db:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 6e2:	77 07                	ja     6eb <morecore+0x16>
    nu = 4096;
 6e4:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 6eb:	8b 45 08             	mov    0x8(%ebp),%eax
 6ee:	c1 e0 03             	shl    $0x3,%eax
 6f1:	89 04 24             	mov    %eax,(%esp)
 6f4:	e8 3f fc ff ff       	call   338 <sbrk>
 6f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 6fc:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 700:	75 07                	jne    709 <morecore+0x34>
    return 0;
 702:	b8 00 00 00 00       	mov    $0x0,%eax
 707:	eb 22                	jmp    72b <morecore+0x56>
  hp = (Header*)p;
 709:	8b 45 f4             	mov    -0xc(%ebp),%eax
 70c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 70f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 712:	8b 55 08             	mov    0x8(%ebp),%edx
 715:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 718:	8b 45 f0             	mov    -0x10(%ebp),%eax
 71b:	83 c0 08             	add    $0x8,%eax
 71e:	89 04 24             	mov    %eax,(%esp)
 721:	e8 ce fe ff ff       	call   5f4 <free>
  return freep;
 726:	a1 a4 0a 00 00       	mov    0xaa4,%eax
}
 72b:	c9                   	leave  
 72c:	c3                   	ret    

0000072d <malloc>:

void*
malloc(uint nbytes)
{
 72d:	55                   	push   %ebp
 72e:	89 e5                	mov    %esp,%ebp
 730:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 733:	8b 45 08             	mov    0x8(%ebp),%eax
 736:	83 c0 07             	add    $0x7,%eax
 739:	c1 e8 03             	shr    $0x3,%eax
 73c:	40                   	inc    %eax
 73d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 740:	a1 a4 0a 00 00       	mov    0xaa4,%eax
 745:	89 45 f0             	mov    %eax,-0x10(%ebp)
 748:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 74c:	75 23                	jne    771 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 74e:	c7 45 f0 9c 0a 00 00 	movl   $0xa9c,-0x10(%ebp)
 755:	8b 45 f0             	mov    -0x10(%ebp),%eax
 758:	a3 a4 0a 00 00       	mov    %eax,0xaa4
 75d:	a1 a4 0a 00 00       	mov    0xaa4,%eax
 762:	a3 9c 0a 00 00       	mov    %eax,0xa9c
    base.s.size = 0;
 767:	c7 05 a0 0a 00 00 00 	movl   $0x0,0xaa0
 76e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 771:	8b 45 f0             	mov    -0x10(%ebp),%eax
 774:	8b 00                	mov    (%eax),%eax
 776:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 779:	8b 45 f4             	mov    -0xc(%ebp),%eax
 77c:	8b 40 04             	mov    0x4(%eax),%eax
 77f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 782:	72 4d                	jb     7d1 <malloc+0xa4>
      if(p->s.size == nunits)
 784:	8b 45 f4             	mov    -0xc(%ebp),%eax
 787:	8b 40 04             	mov    0x4(%eax),%eax
 78a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 78d:	75 0c                	jne    79b <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 78f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 792:	8b 10                	mov    (%eax),%edx
 794:	8b 45 f0             	mov    -0x10(%ebp),%eax
 797:	89 10                	mov    %edx,(%eax)
 799:	eb 26                	jmp    7c1 <malloc+0x94>
      else {
        p->s.size -= nunits;
 79b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 79e:	8b 40 04             	mov    0x4(%eax),%eax
 7a1:	2b 45 ec             	sub    -0x14(%ebp),%eax
 7a4:	89 c2                	mov    %eax,%edx
 7a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a9:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7af:	8b 40 04             	mov    0x4(%eax),%eax
 7b2:	c1 e0 03             	shl    $0x3,%eax
 7b5:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7bb:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7be:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7c4:	a3 a4 0a 00 00       	mov    %eax,0xaa4
      return (void*)(p + 1);
 7c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7cc:	83 c0 08             	add    $0x8,%eax
 7cf:	eb 38                	jmp    809 <malloc+0xdc>
    }
    if(p == freep)
 7d1:	a1 a4 0a 00 00       	mov    0xaa4,%eax
 7d6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 7d9:	75 1b                	jne    7f6 <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 7db:	8b 45 ec             	mov    -0x14(%ebp),%eax
 7de:	89 04 24             	mov    %eax,(%esp)
 7e1:	e8 ef fe ff ff       	call   6d5 <morecore>
 7e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
 7e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7ed:	75 07                	jne    7f6 <malloc+0xc9>
        return 0;
 7ef:	b8 00 00 00 00       	mov    $0x0,%eax
 7f4:	eb 13                	jmp    809 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ff:	8b 00                	mov    (%eax),%eax
 801:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 804:	e9 70 ff ff ff       	jmp    779 <malloc+0x4c>
}
 809:	c9                   	leave  
 80a:	c3                   	ret    
