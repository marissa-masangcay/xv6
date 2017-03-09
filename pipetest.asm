
_pipetest:     file format elf32-i386


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
   6:	83 ec 20             	sub    $0x20,%esp
  printf(1, "Hello, World!\n"); 
   9:	c7 44 24 04 4b 08 00 	movl   $0x84b,0x4(%esp)
  10:	00 
  11:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  18:	e8 68 04 00 00       	call   485 <printf>
  printf(1, "getpid() = %d\n", getpid()); 
  1d:	e8 4e 03 00 00       	call   370 <getpid>
  22:	89 44 24 08          	mov    %eax,0x8(%esp)
  26:	c7 44 24 04 5a 08 00 	movl   $0x85a,0x4(%esp)
  2d:	00 
  2e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  35:	e8 4b 04 00 00       	call   485 <printf>
  printf(1, "mygetpid() = %d\n", mygetpid());
  3a:	e8 51 03 00 00       	call   390 <mygetpid>
  3f:	89 44 24 08          	mov    %eax,0x8(%esp)
  43:	c7 44 24 04 69 08 00 	movl   $0x869,0x4(%esp)
  4a:	00 
  4b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  52:	e8 2e 04 00 00       	call   485 <printf>
  printf(1, "in pipetest.c\n");
  57:	c7 44 24 04 7a 08 00 	movl   $0x87a,0x4(%esp)
  5e:	00 
  5f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  66:	e8 1a 04 00 00       	call   485 <printf>
  int test;
  test = pipe_count(1);
  6b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  72:	e8 29 03 00 00       	call   3a0 <pipe_count>
  77:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  printf(1, "Pipe_count= %d\n", test);
  7b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  7f:	89 44 24 08          	mov    %eax,0x8(%esp)
  83:	c7 44 24 04 89 08 00 	movl   $0x889,0x4(%esp)
  8a:	00 
  8b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  92:	e8 ee 03 00 00       	call   485 <printf>
  exit(); 
  97:	e8 54 02 00 00       	call   2f0 <exit>

0000009c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  9c:	55                   	push   %ebp
  9d:	89 e5                	mov    %esp,%ebp
  9f:	57                   	push   %edi
  a0:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  a4:	8b 55 10             	mov    0x10(%ebp),%edx
  a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  aa:	89 cb                	mov    %ecx,%ebx
  ac:	89 df                	mov    %ebx,%edi
  ae:	89 d1                	mov    %edx,%ecx
  b0:	fc                   	cld    
  b1:	f3 aa                	rep stos %al,%es:(%edi)
  b3:	89 ca                	mov    %ecx,%edx
  b5:	89 fb                	mov    %edi,%ebx
  b7:	89 5d 08             	mov    %ebx,0x8(%ebp)
  ba:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  bd:	5b                   	pop    %ebx
  be:	5f                   	pop    %edi
  bf:	5d                   	pop    %ebp
  c0:	c3                   	ret    

000000c1 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  c1:	55                   	push   %ebp
  c2:	89 e5                	mov    %esp,%ebp
  c4:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  c7:	8b 45 08             	mov    0x8(%ebp),%eax
  ca:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  cd:	90                   	nop
  ce:	8b 45 08             	mov    0x8(%ebp),%eax
  d1:	8d 50 01             	lea    0x1(%eax),%edx
  d4:	89 55 08             	mov    %edx,0x8(%ebp)
  d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  da:	8d 4a 01             	lea    0x1(%edx),%ecx
  dd:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  e0:	8a 12                	mov    (%edx),%dl
  e2:	88 10                	mov    %dl,(%eax)
  e4:	8a 00                	mov    (%eax),%al
  e6:	84 c0                	test   %al,%al
  e8:	75 e4                	jne    ce <strcpy+0xd>
    ;
  return os;
  ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  ed:	c9                   	leave  
  ee:	c3                   	ret    

000000ef <strcmp>:

int
strcmp(const char *p, const char *q)
{
  ef:	55                   	push   %ebp
  f0:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  f2:	eb 06                	jmp    fa <strcmp+0xb>
    p++, q++;
  f4:	ff 45 08             	incl   0x8(%ebp)
  f7:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  fa:	8b 45 08             	mov    0x8(%ebp),%eax
  fd:	8a 00                	mov    (%eax),%al
  ff:	84 c0                	test   %al,%al
 101:	74 0e                	je     111 <strcmp+0x22>
 103:	8b 45 08             	mov    0x8(%ebp),%eax
 106:	8a 10                	mov    (%eax),%dl
 108:	8b 45 0c             	mov    0xc(%ebp),%eax
 10b:	8a 00                	mov    (%eax),%al
 10d:	38 c2                	cmp    %al,%dl
 10f:	74 e3                	je     f4 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 111:	8b 45 08             	mov    0x8(%ebp),%eax
 114:	8a 00                	mov    (%eax),%al
 116:	0f b6 d0             	movzbl %al,%edx
 119:	8b 45 0c             	mov    0xc(%ebp),%eax
 11c:	8a 00                	mov    (%eax),%al
 11e:	0f b6 c0             	movzbl %al,%eax
 121:	29 c2                	sub    %eax,%edx
 123:	89 d0                	mov    %edx,%eax
}
 125:	5d                   	pop    %ebp
 126:	c3                   	ret    

00000127 <strlen>:

uint
strlen(char *s)
{
 127:	55                   	push   %ebp
 128:	89 e5                	mov    %esp,%ebp
 12a:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 12d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 134:	eb 03                	jmp    139 <strlen+0x12>
 136:	ff 45 fc             	incl   -0x4(%ebp)
 139:	8b 55 fc             	mov    -0x4(%ebp),%edx
 13c:	8b 45 08             	mov    0x8(%ebp),%eax
 13f:	01 d0                	add    %edx,%eax
 141:	8a 00                	mov    (%eax),%al
 143:	84 c0                	test   %al,%al
 145:	75 ef                	jne    136 <strlen+0xf>
    ;
  return n;
 147:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 14a:	c9                   	leave  
 14b:	c3                   	ret    

0000014c <memset>:

void*
memset(void *dst, int c, uint n)
{
 14c:	55                   	push   %ebp
 14d:	89 e5                	mov    %esp,%ebp
 14f:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 152:	8b 45 10             	mov    0x10(%ebp),%eax
 155:	89 44 24 08          	mov    %eax,0x8(%esp)
 159:	8b 45 0c             	mov    0xc(%ebp),%eax
 15c:	89 44 24 04          	mov    %eax,0x4(%esp)
 160:	8b 45 08             	mov    0x8(%ebp),%eax
 163:	89 04 24             	mov    %eax,(%esp)
 166:	e8 31 ff ff ff       	call   9c <stosb>
  return dst;
 16b:	8b 45 08             	mov    0x8(%ebp),%eax
}
 16e:	c9                   	leave  
 16f:	c3                   	ret    

00000170 <strchr>:

char*
strchr(const char *s, char c)
{
 170:	55                   	push   %ebp
 171:	89 e5                	mov    %esp,%ebp
 173:	83 ec 04             	sub    $0x4,%esp
 176:	8b 45 0c             	mov    0xc(%ebp),%eax
 179:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 17c:	eb 12                	jmp    190 <strchr+0x20>
    if(*s == c)
 17e:	8b 45 08             	mov    0x8(%ebp),%eax
 181:	8a 00                	mov    (%eax),%al
 183:	3a 45 fc             	cmp    -0x4(%ebp),%al
 186:	75 05                	jne    18d <strchr+0x1d>
      return (char*)s;
 188:	8b 45 08             	mov    0x8(%ebp),%eax
 18b:	eb 11                	jmp    19e <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 18d:	ff 45 08             	incl   0x8(%ebp)
 190:	8b 45 08             	mov    0x8(%ebp),%eax
 193:	8a 00                	mov    (%eax),%al
 195:	84 c0                	test   %al,%al
 197:	75 e5                	jne    17e <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 199:	b8 00 00 00 00       	mov    $0x0,%eax
}
 19e:	c9                   	leave  
 19f:	c3                   	ret    

000001a0 <gets>:

char*
gets(char *buf, int max)
{
 1a0:	55                   	push   %ebp
 1a1:	89 e5                	mov    %esp,%ebp
 1a3:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1a6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1ad:	eb 49                	jmp    1f8 <gets+0x58>
    cc = read(0, &c, 1);
 1af:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 1b6:	00 
 1b7:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1ba:	89 44 24 04          	mov    %eax,0x4(%esp)
 1be:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 1c5:	e8 3e 01 00 00       	call   308 <read>
 1ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1cd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1d1:	7f 02                	jg     1d5 <gets+0x35>
      break;
 1d3:	eb 2c                	jmp    201 <gets+0x61>
    buf[i++] = c;
 1d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1d8:	8d 50 01             	lea    0x1(%eax),%edx
 1db:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1de:	89 c2                	mov    %eax,%edx
 1e0:	8b 45 08             	mov    0x8(%ebp),%eax
 1e3:	01 c2                	add    %eax,%edx
 1e5:	8a 45 ef             	mov    -0x11(%ebp),%al
 1e8:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1ea:	8a 45 ef             	mov    -0x11(%ebp),%al
 1ed:	3c 0a                	cmp    $0xa,%al
 1ef:	74 10                	je     201 <gets+0x61>
 1f1:	8a 45 ef             	mov    -0x11(%ebp),%al
 1f4:	3c 0d                	cmp    $0xd,%al
 1f6:	74 09                	je     201 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1fb:	40                   	inc    %eax
 1fc:	3b 45 0c             	cmp    0xc(%ebp),%eax
 1ff:	7c ae                	jl     1af <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 201:	8b 55 f4             	mov    -0xc(%ebp),%edx
 204:	8b 45 08             	mov    0x8(%ebp),%eax
 207:	01 d0                	add    %edx,%eax
 209:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 20c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 20f:	c9                   	leave  
 210:	c3                   	ret    

00000211 <stat>:

int
stat(char *n, struct stat *st)
{
 211:	55                   	push   %ebp
 212:	89 e5                	mov    %esp,%ebp
 214:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 217:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 21e:	00 
 21f:	8b 45 08             	mov    0x8(%ebp),%eax
 222:	89 04 24             	mov    %eax,(%esp)
 225:	e8 06 01 00 00       	call   330 <open>
 22a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 22d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 231:	79 07                	jns    23a <stat+0x29>
    return -1;
 233:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 238:	eb 23                	jmp    25d <stat+0x4c>
  r = fstat(fd, st);
 23a:	8b 45 0c             	mov    0xc(%ebp),%eax
 23d:	89 44 24 04          	mov    %eax,0x4(%esp)
 241:	8b 45 f4             	mov    -0xc(%ebp),%eax
 244:	89 04 24             	mov    %eax,(%esp)
 247:	e8 fc 00 00 00       	call   348 <fstat>
 24c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 24f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 252:	89 04 24             	mov    %eax,(%esp)
 255:	e8 be 00 00 00       	call   318 <close>
  return r;
 25a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 25d:	c9                   	leave  
 25e:	c3                   	ret    

0000025f <atoi>:

int
atoi(const char *s)
{
 25f:	55                   	push   %ebp
 260:	89 e5                	mov    %esp,%ebp
 262:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 265:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 26c:	eb 24                	jmp    292 <atoi+0x33>
    n = n*10 + *s++ - '0';
 26e:	8b 55 fc             	mov    -0x4(%ebp),%edx
 271:	89 d0                	mov    %edx,%eax
 273:	c1 e0 02             	shl    $0x2,%eax
 276:	01 d0                	add    %edx,%eax
 278:	01 c0                	add    %eax,%eax
 27a:	89 c1                	mov    %eax,%ecx
 27c:	8b 45 08             	mov    0x8(%ebp),%eax
 27f:	8d 50 01             	lea    0x1(%eax),%edx
 282:	89 55 08             	mov    %edx,0x8(%ebp)
 285:	8a 00                	mov    (%eax),%al
 287:	0f be c0             	movsbl %al,%eax
 28a:	01 c8                	add    %ecx,%eax
 28c:	83 e8 30             	sub    $0x30,%eax
 28f:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 292:	8b 45 08             	mov    0x8(%ebp),%eax
 295:	8a 00                	mov    (%eax),%al
 297:	3c 2f                	cmp    $0x2f,%al
 299:	7e 09                	jle    2a4 <atoi+0x45>
 29b:	8b 45 08             	mov    0x8(%ebp),%eax
 29e:	8a 00                	mov    (%eax),%al
 2a0:	3c 39                	cmp    $0x39,%al
 2a2:	7e ca                	jle    26e <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 2a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2a7:	c9                   	leave  
 2a8:	c3                   	ret    

000002a9 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 2a9:	55                   	push   %ebp
 2aa:	89 e5                	mov    %esp,%ebp
 2ac:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 2af:	8b 45 08             	mov    0x8(%ebp),%eax
 2b2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2b5:	8b 45 0c             	mov    0xc(%ebp),%eax
 2b8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2bb:	eb 16                	jmp    2d3 <memmove+0x2a>
    *dst++ = *src++;
 2bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2c0:	8d 50 01             	lea    0x1(%eax),%edx
 2c3:	89 55 fc             	mov    %edx,-0x4(%ebp)
 2c6:	8b 55 f8             	mov    -0x8(%ebp),%edx
 2c9:	8d 4a 01             	lea    0x1(%edx),%ecx
 2cc:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 2cf:	8a 12                	mov    (%edx),%dl
 2d1:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2d3:	8b 45 10             	mov    0x10(%ebp),%eax
 2d6:	8d 50 ff             	lea    -0x1(%eax),%edx
 2d9:	89 55 10             	mov    %edx,0x10(%ebp)
 2dc:	85 c0                	test   %eax,%eax
 2de:	7f dd                	jg     2bd <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 2e0:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2e3:	c9                   	leave  
 2e4:	c3                   	ret    
 2e5:	90                   	nop
 2e6:	90                   	nop
 2e7:	90                   	nop

000002e8 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2e8:	b8 01 00 00 00       	mov    $0x1,%eax
 2ed:	cd 40                	int    $0x40
 2ef:	c3                   	ret    

000002f0 <exit>:
SYSCALL(exit)
 2f0:	b8 02 00 00 00       	mov    $0x2,%eax
 2f5:	cd 40                	int    $0x40
 2f7:	c3                   	ret    

000002f8 <wait>:
SYSCALL(wait)
 2f8:	b8 03 00 00 00       	mov    $0x3,%eax
 2fd:	cd 40                	int    $0x40
 2ff:	c3                   	ret    

00000300 <pipe>:
SYSCALL(pipe)
 300:	b8 04 00 00 00       	mov    $0x4,%eax
 305:	cd 40                	int    $0x40
 307:	c3                   	ret    

00000308 <read>:
SYSCALL(read)
 308:	b8 05 00 00 00       	mov    $0x5,%eax
 30d:	cd 40                	int    $0x40
 30f:	c3                   	ret    

00000310 <write>:
SYSCALL(write)
 310:	b8 10 00 00 00       	mov    $0x10,%eax
 315:	cd 40                	int    $0x40
 317:	c3                   	ret    

00000318 <close>:
SYSCALL(close)
 318:	b8 15 00 00 00       	mov    $0x15,%eax
 31d:	cd 40                	int    $0x40
 31f:	c3                   	ret    

00000320 <kill>:
SYSCALL(kill)
 320:	b8 06 00 00 00       	mov    $0x6,%eax
 325:	cd 40                	int    $0x40
 327:	c3                   	ret    

00000328 <exec>:
SYSCALL(exec)
 328:	b8 07 00 00 00       	mov    $0x7,%eax
 32d:	cd 40                	int    $0x40
 32f:	c3                   	ret    

00000330 <open>:
SYSCALL(open)
 330:	b8 0f 00 00 00       	mov    $0xf,%eax
 335:	cd 40                	int    $0x40
 337:	c3                   	ret    

00000338 <mknod>:
SYSCALL(mknod)
 338:	b8 11 00 00 00       	mov    $0x11,%eax
 33d:	cd 40                	int    $0x40
 33f:	c3                   	ret    

00000340 <unlink>:
SYSCALL(unlink)
 340:	b8 12 00 00 00       	mov    $0x12,%eax
 345:	cd 40                	int    $0x40
 347:	c3                   	ret    

00000348 <fstat>:
SYSCALL(fstat)
 348:	b8 08 00 00 00       	mov    $0x8,%eax
 34d:	cd 40                	int    $0x40
 34f:	c3                   	ret    

00000350 <link>:
SYSCALL(link)
 350:	b8 13 00 00 00       	mov    $0x13,%eax
 355:	cd 40                	int    $0x40
 357:	c3                   	ret    

00000358 <mkdir>:
SYSCALL(mkdir)
 358:	b8 14 00 00 00       	mov    $0x14,%eax
 35d:	cd 40                	int    $0x40
 35f:	c3                   	ret    

00000360 <chdir>:
SYSCALL(chdir)
 360:	b8 09 00 00 00       	mov    $0x9,%eax
 365:	cd 40                	int    $0x40
 367:	c3                   	ret    

00000368 <dup>:
SYSCALL(dup)
 368:	b8 0a 00 00 00       	mov    $0xa,%eax
 36d:	cd 40                	int    $0x40
 36f:	c3                   	ret    

00000370 <getpid>:
SYSCALL(getpid)
 370:	b8 0b 00 00 00       	mov    $0xb,%eax
 375:	cd 40                	int    $0x40
 377:	c3                   	ret    

00000378 <sbrk>:
SYSCALL(sbrk)
 378:	b8 0c 00 00 00       	mov    $0xc,%eax
 37d:	cd 40                	int    $0x40
 37f:	c3                   	ret    

00000380 <sleep>:
SYSCALL(sleep)
 380:	b8 0d 00 00 00       	mov    $0xd,%eax
 385:	cd 40                	int    $0x40
 387:	c3                   	ret    

00000388 <uptime>:
SYSCALL(uptime)
 388:	b8 0e 00 00 00       	mov    $0xe,%eax
 38d:	cd 40                	int    $0x40
 38f:	c3                   	ret    

00000390 <mygetpid>:
SYSCALL(mygetpid)
 390:	b8 16 00 00 00       	mov    $0x16,%eax
 395:	cd 40                	int    $0x40
 397:	c3                   	ret    

00000398 <halt>:
SYSCALL(halt)
 398:	b8 17 00 00 00       	mov    $0x17,%eax
 39d:	cd 40                	int    $0x40
 39f:	c3                   	ret    

000003a0 <pipe_count>:
SYSCALL(pipe_count)
 3a0:	b8 18 00 00 00       	mov    $0x18,%eax
 3a5:	cd 40                	int    $0x40
 3a7:	c3                   	ret    

000003a8 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3a8:	55                   	push   %ebp
 3a9:	89 e5                	mov    %esp,%ebp
 3ab:	83 ec 18             	sub    $0x18,%esp
 3ae:	8b 45 0c             	mov    0xc(%ebp),%eax
 3b1:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 3b4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 3bb:	00 
 3bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
 3bf:	89 44 24 04          	mov    %eax,0x4(%esp)
 3c3:	8b 45 08             	mov    0x8(%ebp),%eax
 3c6:	89 04 24             	mov    %eax,(%esp)
 3c9:	e8 42 ff ff ff       	call   310 <write>
}
 3ce:	c9                   	leave  
 3cf:	c3                   	ret    

000003d0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3d0:	55                   	push   %ebp
 3d1:	89 e5                	mov    %esp,%ebp
 3d3:	56                   	push   %esi
 3d4:	53                   	push   %ebx
 3d5:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3d8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3df:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3e3:	74 17                	je     3fc <printint+0x2c>
 3e5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3e9:	79 11                	jns    3fc <printint+0x2c>
    neg = 1;
 3eb:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3f2:	8b 45 0c             	mov    0xc(%ebp),%eax
 3f5:	f7 d8                	neg    %eax
 3f7:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3fa:	eb 06                	jmp    402 <printint+0x32>
  } else {
    x = xx;
 3fc:	8b 45 0c             	mov    0xc(%ebp),%eax
 3ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 402:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 409:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 40c:	8d 41 01             	lea    0x1(%ecx),%eax
 40f:	89 45 f4             	mov    %eax,-0xc(%ebp)
 412:	8b 5d 10             	mov    0x10(%ebp),%ebx
 415:	8b 45 ec             	mov    -0x14(%ebp),%eax
 418:	ba 00 00 00 00       	mov    $0x0,%edx
 41d:	f7 f3                	div    %ebx
 41f:	89 d0                	mov    %edx,%eax
 421:	8a 80 e4 0a 00 00    	mov    0xae4(%eax),%al
 427:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 42b:	8b 75 10             	mov    0x10(%ebp),%esi
 42e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 431:	ba 00 00 00 00       	mov    $0x0,%edx
 436:	f7 f6                	div    %esi
 438:	89 45 ec             	mov    %eax,-0x14(%ebp)
 43b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 43f:	75 c8                	jne    409 <printint+0x39>
  if(neg)
 441:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 445:	74 10                	je     457 <printint+0x87>
    buf[i++] = '-';
 447:	8b 45 f4             	mov    -0xc(%ebp),%eax
 44a:	8d 50 01             	lea    0x1(%eax),%edx
 44d:	89 55 f4             	mov    %edx,-0xc(%ebp)
 450:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 455:	eb 1e                	jmp    475 <printint+0xa5>
 457:	eb 1c                	jmp    475 <printint+0xa5>
    putc(fd, buf[i]);
 459:	8d 55 dc             	lea    -0x24(%ebp),%edx
 45c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 45f:	01 d0                	add    %edx,%eax
 461:	8a 00                	mov    (%eax),%al
 463:	0f be c0             	movsbl %al,%eax
 466:	89 44 24 04          	mov    %eax,0x4(%esp)
 46a:	8b 45 08             	mov    0x8(%ebp),%eax
 46d:	89 04 24             	mov    %eax,(%esp)
 470:	e8 33 ff ff ff       	call   3a8 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 475:	ff 4d f4             	decl   -0xc(%ebp)
 478:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 47c:	79 db                	jns    459 <printint+0x89>
    putc(fd, buf[i]);
}
 47e:	83 c4 30             	add    $0x30,%esp
 481:	5b                   	pop    %ebx
 482:	5e                   	pop    %esi
 483:	5d                   	pop    %ebp
 484:	c3                   	ret    

00000485 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 485:	55                   	push   %ebp
 486:	89 e5                	mov    %esp,%ebp
 488:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 48b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 492:	8d 45 0c             	lea    0xc(%ebp),%eax
 495:	83 c0 04             	add    $0x4,%eax
 498:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 49b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4a2:	e9 77 01 00 00       	jmp    61e <printf+0x199>
    c = fmt[i] & 0xff;
 4a7:	8b 55 0c             	mov    0xc(%ebp),%edx
 4aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4ad:	01 d0                	add    %edx,%eax
 4af:	8a 00                	mov    (%eax),%al
 4b1:	0f be c0             	movsbl %al,%eax
 4b4:	25 ff 00 00 00       	and    $0xff,%eax
 4b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 4bc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4c0:	75 2c                	jne    4ee <printf+0x69>
      if(c == '%'){
 4c2:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4c6:	75 0c                	jne    4d4 <printf+0x4f>
        state = '%';
 4c8:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 4cf:	e9 47 01 00 00       	jmp    61b <printf+0x196>
      } else {
        putc(fd, c);
 4d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4d7:	0f be c0             	movsbl %al,%eax
 4da:	89 44 24 04          	mov    %eax,0x4(%esp)
 4de:	8b 45 08             	mov    0x8(%ebp),%eax
 4e1:	89 04 24             	mov    %eax,(%esp)
 4e4:	e8 bf fe ff ff       	call   3a8 <putc>
 4e9:	e9 2d 01 00 00       	jmp    61b <printf+0x196>
      }
    } else if(state == '%'){
 4ee:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4f2:	0f 85 23 01 00 00    	jne    61b <printf+0x196>
      if(c == 'd'){
 4f8:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4fc:	75 2d                	jne    52b <printf+0xa6>
        printint(fd, *ap, 10, 1);
 4fe:	8b 45 e8             	mov    -0x18(%ebp),%eax
 501:	8b 00                	mov    (%eax),%eax
 503:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 50a:	00 
 50b:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 512:	00 
 513:	89 44 24 04          	mov    %eax,0x4(%esp)
 517:	8b 45 08             	mov    0x8(%ebp),%eax
 51a:	89 04 24             	mov    %eax,(%esp)
 51d:	e8 ae fe ff ff       	call   3d0 <printint>
        ap++;
 522:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 526:	e9 e9 00 00 00       	jmp    614 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 52b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 52f:	74 06                	je     537 <printf+0xb2>
 531:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 535:	75 2d                	jne    564 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 537:	8b 45 e8             	mov    -0x18(%ebp),%eax
 53a:	8b 00                	mov    (%eax),%eax
 53c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 543:	00 
 544:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 54b:	00 
 54c:	89 44 24 04          	mov    %eax,0x4(%esp)
 550:	8b 45 08             	mov    0x8(%ebp),%eax
 553:	89 04 24             	mov    %eax,(%esp)
 556:	e8 75 fe ff ff       	call   3d0 <printint>
        ap++;
 55b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 55f:	e9 b0 00 00 00       	jmp    614 <printf+0x18f>
      } else if(c == 's'){
 564:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 568:	75 42                	jne    5ac <printf+0x127>
        s = (char*)*ap;
 56a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 56d:	8b 00                	mov    (%eax),%eax
 56f:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 572:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 576:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 57a:	75 09                	jne    585 <printf+0x100>
          s = "(null)";
 57c:	c7 45 f4 99 08 00 00 	movl   $0x899,-0xc(%ebp)
        while(*s != 0){
 583:	eb 1c                	jmp    5a1 <printf+0x11c>
 585:	eb 1a                	jmp    5a1 <printf+0x11c>
          putc(fd, *s);
 587:	8b 45 f4             	mov    -0xc(%ebp),%eax
 58a:	8a 00                	mov    (%eax),%al
 58c:	0f be c0             	movsbl %al,%eax
 58f:	89 44 24 04          	mov    %eax,0x4(%esp)
 593:	8b 45 08             	mov    0x8(%ebp),%eax
 596:	89 04 24             	mov    %eax,(%esp)
 599:	e8 0a fe ff ff       	call   3a8 <putc>
          s++;
 59e:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 5a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5a4:	8a 00                	mov    (%eax),%al
 5a6:	84 c0                	test   %al,%al
 5a8:	75 dd                	jne    587 <printf+0x102>
 5aa:	eb 68                	jmp    614 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5ac:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 5b0:	75 1d                	jne    5cf <printf+0x14a>
        putc(fd, *ap);
 5b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5b5:	8b 00                	mov    (%eax),%eax
 5b7:	0f be c0             	movsbl %al,%eax
 5ba:	89 44 24 04          	mov    %eax,0x4(%esp)
 5be:	8b 45 08             	mov    0x8(%ebp),%eax
 5c1:	89 04 24             	mov    %eax,(%esp)
 5c4:	e8 df fd ff ff       	call   3a8 <putc>
        ap++;
 5c9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5cd:	eb 45                	jmp    614 <printf+0x18f>
      } else if(c == '%'){
 5cf:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5d3:	75 17                	jne    5ec <printf+0x167>
        putc(fd, c);
 5d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5d8:	0f be c0             	movsbl %al,%eax
 5db:	89 44 24 04          	mov    %eax,0x4(%esp)
 5df:	8b 45 08             	mov    0x8(%ebp),%eax
 5e2:	89 04 24             	mov    %eax,(%esp)
 5e5:	e8 be fd ff ff       	call   3a8 <putc>
 5ea:	eb 28                	jmp    614 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5ec:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 5f3:	00 
 5f4:	8b 45 08             	mov    0x8(%ebp),%eax
 5f7:	89 04 24             	mov    %eax,(%esp)
 5fa:	e8 a9 fd ff ff       	call   3a8 <putc>
        putc(fd, c);
 5ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 602:	0f be c0             	movsbl %al,%eax
 605:	89 44 24 04          	mov    %eax,0x4(%esp)
 609:	8b 45 08             	mov    0x8(%ebp),%eax
 60c:	89 04 24             	mov    %eax,(%esp)
 60f:	e8 94 fd ff ff       	call   3a8 <putc>
      }
      state = 0;
 614:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 61b:	ff 45 f0             	incl   -0x10(%ebp)
 61e:	8b 55 0c             	mov    0xc(%ebp),%edx
 621:	8b 45 f0             	mov    -0x10(%ebp),%eax
 624:	01 d0                	add    %edx,%eax
 626:	8a 00                	mov    (%eax),%al
 628:	84 c0                	test   %al,%al
 62a:	0f 85 77 fe ff ff    	jne    4a7 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 630:	c9                   	leave  
 631:	c3                   	ret    
 632:	90                   	nop
 633:	90                   	nop

00000634 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 634:	55                   	push   %ebp
 635:	89 e5                	mov    %esp,%ebp
 637:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 63a:	8b 45 08             	mov    0x8(%ebp),%eax
 63d:	83 e8 08             	sub    $0x8,%eax
 640:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 643:	a1 00 0b 00 00       	mov    0xb00,%eax
 648:	89 45 fc             	mov    %eax,-0x4(%ebp)
 64b:	eb 24                	jmp    671 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 64d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 650:	8b 00                	mov    (%eax),%eax
 652:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 655:	77 12                	ja     669 <free+0x35>
 657:	8b 45 f8             	mov    -0x8(%ebp),%eax
 65a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 65d:	77 24                	ja     683 <free+0x4f>
 65f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 662:	8b 00                	mov    (%eax),%eax
 664:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 667:	77 1a                	ja     683 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 669:	8b 45 fc             	mov    -0x4(%ebp),%eax
 66c:	8b 00                	mov    (%eax),%eax
 66e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 671:	8b 45 f8             	mov    -0x8(%ebp),%eax
 674:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 677:	76 d4                	jbe    64d <free+0x19>
 679:	8b 45 fc             	mov    -0x4(%ebp),%eax
 67c:	8b 00                	mov    (%eax),%eax
 67e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 681:	76 ca                	jbe    64d <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 683:	8b 45 f8             	mov    -0x8(%ebp),%eax
 686:	8b 40 04             	mov    0x4(%eax),%eax
 689:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 690:	8b 45 f8             	mov    -0x8(%ebp),%eax
 693:	01 c2                	add    %eax,%edx
 695:	8b 45 fc             	mov    -0x4(%ebp),%eax
 698:	8b 00                	mov    (%eax),%eax
 69a:	39 c2                	cmp    %eax,%edx
 69c:	75 24                	jne    6c2 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 69e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6a1:	8b 50 04             	mov    0x4(%eax),%edx
 6a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a7:	8b 00                	mov    (%eax),%eax
 6a9:	8b 40 04             	mov    0x4(%eax),%eax
 6ac:	01 c2                	add    %eax,%edx
 6ae:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b1:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 6b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b7:	8b 00                	mov    (%eax),%eax
 6b9:	8b 10                	mov    (%eax),%edx
 6bb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6be:	89 10                	mov    %edx,(%eax)
 6c0:	eb 0a                	jmp    6cc <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 6c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c5:	8b 10                	mov    (%eax),%edx
 6c7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ca:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 6cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6cf:	8b 40 04             	mov    0x4(%eax),%eax
 6d2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6dc:	01 d0                	add    %edx,%eax
 6de:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6e1:	75 20                	jne    703 <free+0xcf>
    p->s.size += bp->s.size;
 6e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e6:	8b 50 04             	mov    0x4(%eax),%edx
 6e9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ec:	8b 40 04             	mov    0x4(%eax),%eax
 6ef:	01 c2                	add    %eax,%edx
 6f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f4:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6f7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6fa:	8b 10                	mov    (%eax),%edx
 6fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ff:	89 10                	mov    %edx,(%eax)
 701:	eb 08                	jmp    70b <free+0xd7>
  } else
    p->s.ptr = bp;
 703:	8b 45 fc             	mov    -0x4(%ebp),%eax
 706:	8b 55 f8             	mov    -0x8(%ebp),%edx
 709:	89 10                	mov    %edx,(%eax)
  freep = p;
 70b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 70e:	a3 00 0b 00 00       	mov    %eax,0xb00
}
 713:	c9                   	leave  
 714:	c3                   	ret    

00000715 <morecore>:

static Header*
morecore(uint nu)
{
 715:	55                   	push   %ebp
 716:	89 e5                	mov    %esp,%ebp
 718:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 71b:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 722:	77 07                	ja     72b <morecore+0x16>
    nu = 4096;
 724:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 72b:	8b 45 08             	mov    0x8(%ebp),%eax
 72e:	c1 e0 03             	shl    $0x3,%eax
 731:	89 04 24             	mov    %eax,(%esp)
 734:	e8 3f fc ff ff       	call   378 <sbrk>
 739:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 73c:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 740:	75 07                	jne    749 <morecore+0x34>
    return 0;
 742:	b8 00 00 00 00       	mov    $0x0,%eax
 747:	eb 22                	jmp    76b <morecore+0x56>
  hp = (Header*)p;
 749:	8b 45 f4             	mov    -0xc(%ebp),%eax
 74c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 74f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 752:	8b 55 08             	mov    0x8(%ebp),%edx
 755:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 758:	8b 45 f0             	mov    -0x10(%ebp),%eax
 75b:	83 c0 08             	add    $0x8,%eax
 75e:	89 04 24             	mov    %eax,(%esp)
 761:	e8 ce fe ff ff       	call   634 <free>
  return freep;
 766:	a1 00 0b 00 00       	mov    0xb00,%eax
}
 76b:	c9                   	leave  
 76c:	c3                   	ret    

0000076d <malloc>:

void*
malloc(uint nbytes)
{
 76d:	55                   	push   %ebp
 76e:	89 e5                	mov    %esp,%ebp
 770:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 773:	8b 45 08             	mov    0x8(%ebp),%eax
 776:	83 c0 07             	add    $0x7,%eax
 779:	c1 e8 03             	shr    $0x3,%eax
 77c:	40                   	inc    %eax
 77d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 780:	a1 00 0b 00 00       	mov    0xb00,%eax
 785:	89 45 f0             	mov    %eax,-0x10(%ebp)
 788:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 78c:	75 23                	jne    7b1 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 78e:	c7 45 f0 f8 0a 00 00 	movl   $0xaf8,-0x10(%ebp)
 795:	8b 45 f0             	mov    -0x10(%ebp),%eax
 798:	a3 00 0b 00 00       	mov    %eax,0xb00
 79d:	a1 00 0b 00 00       	mov    0xb00,%eax
 7a2:	a3 f8 0a 00 00       	mov    %eax,0xaf8
    base.s.size = 0;
 7a7:	c7 05 fc 0a 00 00 00 	movl   $0x0,0xafc
 7ae:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7b4:	8b 00                	mov    (%eax),%eax
 7b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7bc:	8b 40 04             	mov    0x4(%eax),%eax
 7bf:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7c2:	72 4d                	jb     811 <malloc+0xa4>
      if(p->s.size == nunits)
 7c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c7:	8b 40 04             	mov    0x4(%eax),%eax
 7ca:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7cd:	75 0c                	jne    7db <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 7cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d2:	8b 10                	mov    (%eax),%edx
 7d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7d7:	89 10                	mov    %edx,(%eax)
 7d9:	eb 26                	jmp    801 <malloc+0x94>
      else {
        p->s.size -= nunits;
 7db:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7de:	8b 40 04             	mov    0x4(%eax),%eax
 7e1:	2b 45 ec             	sub    -0x14(%ebp),%eax
 7e4:	89 c2                	mov    %eax,%edx
 7e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e9:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ef:	8b 40 04             	mov    0x4(%eax),%eax
 7f2:	c1 e0 03             	shl    $0x3,%eax
 7f5:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7fb:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7fe:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 801:	8b 45 f0             	mov    -0x10(%ebp),%eax
 804:	a3 00 0b 00 00       	mov    %eax,0xb00
      return (void*)(p + 1);
 809:	8b 45 f4             	mov    -0xc(%ebp),%eax
 80c:	83 c0 08             	add    $0x8,%eax
 80f:	eb 38                	jmp    849 <malloc+0xdc>
    }
    if(p == freep)
 811:	a1 00 0b 00 00       	mov    0xb00,%eax
 816:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 819:	75 1b                	jne    836 <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 81b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 81e:	89 04 24             	mov    %eax,(%esp)
 821:	e8 ef fe ff ff       	call   715 <morecore>
 826:	89 45 f4             	mov    %eax,-0xc(%ebp)
 829:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 82d:	75 07                	jne    836 <malloc+0xc9>
        return 0;
 82f:	b8 00 00 00 00       	mov    $0x0,%eax
 834:	eb 13                	jmp    849 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 836:	8b 45 f4             	mov    -0xc(%ebp),%eax
 839:	89 45 f0             	mov    %eax,-0x10(%ebp)
 83c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 83f:	8b 00                	mov    (%eax),%eax
 841:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 844:	e9 70 ff ff ff       	jmp    7b9 <malloc+0x4c>
}
 849:	c9                   	leave  
 84a:	c3                   	ret    
