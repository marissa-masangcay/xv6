
_ln:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 10             	sub    $0x10,%esp
  if(argc != 3){
   9:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
   d:	74 19                	je     28 <main+0x28>
    printf(2, "Usage: ln old new\n");
   f:	c7 44 24 04 2b 08 00 	movl   $0x82b,0x4(%esp)
  16:	00 
  17:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  1e:	e8 42 04 00 00       	call   465 <printf>
    exit();
  23:	e8 a8 02 00 00       	call   2d0 <exit>
  }
  if(link(argv[1], argv[2]) < 0)
  28:	8b 45 0c             	mov    0xc(%ebp),%eax
  2b:	83 c0 08             	add    $0x8,%eax
  2e:	8b 10                	mov    (%eax),%edx
  30:	8b 45 0c             	mov    0xc(%ebp),%eax
  33:	83 c0 04             	add    $0x4,%eax
  36:	8b 00                	mov    (%eax),%eax
  38:	89 54 24 04          	mov    %edx,0x4(%esp)
  3c:	89 04 24             	mov    %eax,(%esp)
  3f:	e8 ec 02 00 00       	call   330 <link>
  44:	85 c0                	test   %eax,%eax
  46:	79 2c                	jns    74 <main+0x74>
    printf(2, "link %s %s: failed\n", argv[1], argv[2]);
  48:	8b 45 0c             	mov    0xc(%ebp),%eax
  4b:	83 c0 08             	add    $0x8,%eax
  4e:	8b 10                	mov    (%eax),%edx
  50:	8b 45 0c             	mov    0xc(%ebp),%eax
  53:	83 c0 04             	add    $0x4,%eax
  56:	8b 00                	mov    (%eax),%eax
  58:	89 54 24 0c          	mov    %edx,0xc(%esp)
  5c:	89 44 24 08          	mov    %eax,0x8(%esp)
  60:	c7 44 24 04 3e 08 00 	movl   $0x83e,0x4(%esp)
  67:	00 
  68:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  6f:	e8 f1 03 00 00       	call   465 <printf>
  exit();
  74:	e8 57 02 00 00       	call   2d0 <exit>
  79:	90                   	nop
  7a:	90                   	nop
  7b:	90                   	nop

0000007c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  7c:	55                   	push   %ebp
  7d:	89 e5                	mov    %esp,%ebp
  7f:	57                   	push   %edi
  80:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  81:	8b 4d 08             	mov    0x8(%ebp),%ecx
  84:	8b 55 10             	mov    0x10(%ebp),%edx
  87:	8b 45 0c             	mov    0xc(%ebp),%eax
  8a:	89 cb                	mov    %ecx,%ebx
  8c:	89 df                	mov    %ebx,%edi
  8e:	89 d1                	mov    %edx,%ecx
  90:	fc                   	cld    
  91:	f3 aa                	rep stos %al,%es:(%edi)
  93:	89 ca                	mov    %ecx,%edx
  95:	89 fb                	mov    %edi,%ebx
  97:	89 5d 08             	mov    %ebx,0x8(%ebp)
  9a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  9d:	5b                   	pop    %ebx
  9e:	5f                   	pop    %edi
  9f:	5d                   	pop    %ebp
  a0:	c3                   	ret    

000000a1 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  a1:	55                   	push   %ebp
  a2:	89 e5                	mov    %esp,%ebp
  a4:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  a7:	8b 45 08             	mov    0x8(%ebp),%eax
  aa:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  ad:	90                   	nop
  ae:	8b 45 08             	mov    0x8(%ebp),%eax
  b1:	8d 50 01             	lea    0x1(%eax),%edx
  b4:	89 55 08             	mov    %edx,0x8(%ebp)
  b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  ba:	8d 4a 01             	lea    0x1(%edx),%ecx
  bd:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  c0:	8a 12                	mov    (%edx),%dl
  c2:	88 10                	mov    %dl,(%eax)
  c4:	8a 00                	mov    (%eax),%al
  c6:	84 c0                	test   %al,%al
  c8:	75 e4                	jne    ae <strcpy+0xd>
    ;
  return os;
  ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  cd:	c9                   	leave  
  ce:	c3                   	ret    

000000cf <strcmp>:

int
strcmp(const char *p, const char *q)
{
  cf:	55                   	push   %ebp
  d0:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  d2:	eb 06                	jmp    da <strcmp+0xb>
    p++, q++;
  d4:	ff 45 08             	incl   0x8(%ebp)
  d7:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  da:	8b 45 08             	mov    0x8(%ebp),%eax
  dd:	8a 00                	mov    (%eax),%al
  df:	84 c0                	test   %al,%al
  e1:	74 0e                	je     f1 <strcmp+0x22>
  e3:	8b 45 08             	mov    0x8(%ebp),%eax
  e6:	8a 10                	mov    (%eax),%dl
  e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  eb:	8a 00                	mov    (%eax),%al
  ed:	38 c2                	cmp    %al,%dl
  ef:	74 e3                	je     d4 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  f1:	8b 45 08             	mov    0x8(%ebp),%eax
  f4:	8a 00                	mov    (%eax),%al
  f6:	0f b6 d0             	movzbl %al,%edx
  f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  fc:	8a 00                	mov    (%eax),%al
  fe:	0f b6 c0             	movzbl %al,%eax
 101:	29 c2                	sub    %eax,%edx
 103:	89 d0                	mov    %edx,%eax
}
 105:	5d                   	pop    %ebp
 106:	c3                   	ret    

00000107 <strlen>:

uint
strlen(char *s)
{
 107:	55                   	push   %ebp
 108:	89 e5                	mov    %esp,%ebp
 10a:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 10d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 114:	eb 03                	jmp    119 <strlen+0x12>
 116:	ff 45 fc             	incl   -0x4(%ebp)
 119:	8b 55 fc             	mov    -0x4(%ebp),%edx
 11c:	8b 45 08             	mov    0x8(%ebp),%eax
 11f:	01 d0                	add    %edx,%eax
 121:	8a 00                	mov    (%eax),%al
 123:	84 c0                	test   %al,%al
 125:	75 ef                	jne    116 <strlen+0xf>
    ;
  return n;
 127:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 12a:	c9                   	leave  
 12b:	c3                   	ret    

0000012c <memset>:

void*
memset(void *dst, int c, uint n)
{
 12c:	55                   	push   %ebp
 12d:	89 e5                	mov    %esp,%ebp
 12f:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 132:	8b 45 10             	mov    0x10(%ebp),%eax
 135:	89 44 24 08          	mov    %eax,0x8(%esp)
 139:	8b 45 0c             	mov    0xc(%ebp),%eax
 13c:	89 44 24 04          	mov    %eax,0x4(%esp)
 140:	8b 45 08             	mov    0x8(%ebp),%eax
 143:	89 04 24             	mov    %eax,(%esp)
 146:	e8 31 ff ff ff       	call   7c <stosb>
  return dst;
 14b:	8b 45 08             	mov    0x8(%ebp),%eax
}
 14e:	c9                   	leave  
 14f:	c3                   	ret    

00000150 <strchr>:

char*
strchr(const char *s, char c)
{
 150:	55                   	push   %ebp
 151:	89 e5                	mov    %esp,%ebp
 153:	83 ec 04             	sub    $0x4,%esp
 156:	8b 45 0c             	mov    0xc(%ebp),%eax
 159:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 15c:	eb 12                	jmp    170 <strchr+0x20>
    if(*s == c)
 15e:	8b 45 08             	mov    0x8(%ebp),%eax
 161:	8a 00                	mov    (%eax),%al
 163:	3a 45 fc             	cmp    -0x4(%ebp),%al
 166:	75 05                	jne    16d <strchr+0x1d>
      return (char*)s;
 168:	8b 45 08             	mov    0x8(%ebp),%eax
 16b:	eb 11                	jmp    17e <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 16d:	ff 45 08             	incl   0x8(%ebp)
 170:	8b 45 08             	mov    0x8(%ebp),%eax
 173:	8a 00                	mov    (%eax),%al
 175:	84 c0                	test   %al,%al
 177:	75 e5                	jne    15e <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 179:	b8 00 00 00 00       	mov    $0x0,%eax
}
 17e:	c9                   	leave  
 17f:	c3                   	ret    

00000180 <gets>:

char*
gets(char *buf, int max)
{
 180:	55                   	push   %ebp
 181:	89 e5                	mov    %esp,%ebp
 183:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 186:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 18d:	eb 49                	jmp    1d8 <gets+0x58>
    cc = read(0, &c, 1);
 18f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 196:	00 
 197:	8d 45 ef             	lea    -0x11(%ebp),%eax
 19a:	89 44 24 04          	mov    %eax,0x4(%esp)
 19e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 1a5:	e8 3e 01 00 00       	call   2e8 <read>
 1aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1ad:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1b1:	7f 02                	jg     1b5 <gets+0x35>
      break;
 1b3:	eb 2c                	jmp    1e1 <gets+0x61>
    buf[i++] = c;
 1b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1b8:	8d 50 01             	lea    0x1(%eax),%edx
 1bb:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1be:	89 c2                	mov    %eax,%edx
 1c0:	8b 45 08             	mov    0x8(%ebp),%eax
 1c3:	01 c2                	add    %eax,%edx
 1c5:	8a 45 ef             	mov    -0x11(%ebp),%al
 1c8:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1ca:	8a 45 ef             	mov    -0x11(%ebp),%al
 1cd:	3c 0a                	cmp    $0xa,%al
 1cf:	74 10                	je     1e1 <gets+0x61>
 1d1:	8a 45 ef             	mov    -0x11(%ebp),%al
 1d4:	3c 0d                	cmp    $0xd,%al
 1d6:	74 09                	je     1e1 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1db:	40                   	inc    %eax
 1dc:	3b 45 0c             	cmp    0xc(%ebp),%eax
 1df:	7c ae                	jl     18f <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 1e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1e4:	8b 45 08             	mov    0x8(%ebp),%eax
 1e7:	01 d0                	add    %edx,%eax
 1e9:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1ec:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1ef:	c9                   	leave  
 1f0:	c3                   	ret    

000001f1 <stat>:

int
stat(char *n, struct stat *st)
{
 1f1:	55                   	push   %ebp
 1f2:	89 e5                	mov    %esp,%ebp
 1f4:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1f7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 1fe:	00 
 1ff:	8b 45 08             	mov    0x8(%ebp),%eax
 202:	89 04 24             	mov    %eax,(%esp)
 205:	e8 06 01 00 00       	call   310 <open>
 20a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 20d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 211:	79 07                	jns    21a <stat+0x29>
    return -1;
 213:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 218:	eb 23                	jmp    23d <stat+0x4c>
  r = fstat(fd, st);
 21a:	8b 45 0c             	mov    0xc(%ebp),%eax
 21d:	89 44 24 04          	mov    %eax,0x4(%esp)
 221:	8b 45 f4             	mov    -0xc(%ebp),%eax
 224:	89 04 24             	mov    %eax,(%esp)
 227:	e8 fc 00 00 00       	call   328 <fstat>
 22c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 22f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 232:	89 04 24             	mov    %eax,(%esp)
 235:	e8 be 00 00 00       	call   2f8 <close>
  return r;
 23a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 23d:	c9                   	leave  
 23e:	c3                   	ret    

0000023f <atoi>:

int
atoi(const char *s)
{
 23f:	55                   	push   %ebp
 240:	89 e5                	mov    %esp,%ebp
 242:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 245:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 24c:	eb 24                	jmp    272 <atoi+0x33>
    n = n*10 + *s++ - '0';
 24e:	8b 55 fc             	mov    -0x4(%ebp),%edx
 251:	89 d0                	mov    %edx,%eax
 253:	c1 e0 02             	shl    $0x2,%eax
 256:	01 d0                	add    %edx,%eax
 258:	01 c0                	add    %eax,%eax
 25a:	89 c1                	mov    %eax,%ecx
 25c:	8b 45 08             	mov    0x8(%ebp),%eax
 25f:	8d 50 01             	lea    0x1(%eax),%edx
 262:	89 55 08             	mov    %edx,0x8(%ebp)
 265:	8a 00                	mov    (%eax),%al
 267:	0f be c0             	movsbl %al,%eax
 26a:	01 c8                	add    %ecx,%eax
 26c:	83 e8 30             	sub    $0x30,%eax
 26f:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 272:	8b 45 08             	mov    0x8(%ebp),%eax
 275:	8a 00                	mov    (%eax),%al
 277:	3c 2f                	cmp    $0x2f,%al
 279:	7e 09                	jle    284 <atoi+0x45>
 27b:	8b 45 08             	mov    0x8(%ebp),%eax
 27e:	8a 00                	mov    (%eax),%al
 280:	3c 39                	cmp    $0x39,%al
 282:	7e ca                	jle    24e <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 284:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 287:	c9                   	leave  
 288:	c3                   	ret    

00000289 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 289:	55                   	push   %ebp
 28a:	89 e5                	mov    %esp,%ebp
 28c:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 28f:	8b 45 08             	mov    0x8(%ebp),%eax
 292:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 295:	8b 45 0c             	mov    0xc(%ebp),%eax
 298:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 29b:	eb 16                	jmp    2b3 <memmove+0x2a>
    *dst++ = *src++;
 29d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2a0:	8d 50 01             	lea    0x1(%eax),%edx
 2a3:	89 55 fc             	mov    %edx,-0x4(%ebp)
 2a6:	8b 55 f8             	mov    -0x8(%ebp),%edx
 2a9:	8d 4a 01             	lea    0x1(%edx),%ecx
 2ac:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 2af:	8a 12                	mov    (%edx),%dl
 2b1:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2b3:	8b 45 10             	mov    0x10(%ebp),%eax
 2b6:	8d 50 ff             	lea    -0x1(%eax),%edx
 2b9:	89 55 10             	mov    %edx,0x10(%ebp)
 2bc:	85 c0                	test   %eax,%eax
 2be:	7f dd                	jg     29d <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 2c0:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2c3:	c9                   	leave  
 2c4:	c3                   	ret    
 2c5:	90                   	nop
 2c6:	90                   	nop
 2c7:	90                   	nop

000002c8 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2c8:	b8 01 00 00 00       	mov    $0x1,%eax
 2cd:	cd 40                	int    $0x40
 2cf:	c3                   	ret    

000002d0 <exit>:
SYSCALL(exit)
 2d0:	b8 02 00 00 00       	mov    $0x2,%eax
 2d5:	cd 40                	int    $0x40
 2d7:	c3                   	ret    

000002d8 <wait>:
SYSCALL(wait)
 2d8:	b8 03 00 00 00       	mov    $0x3,%eax
 2dd:	cd 40                	int    $0x40
 2df:	c3                   	ret    

000002e0 <pipe>:
SYSCALL(pipe)
 2e0:	b8 04 00 00 00       	mov    $0x4,%eax
 2e5:	cd 40                	int    $0x40
 2e7:	c3                   	ret    

000002e8 <read>:
SYSCALL(read)
 2e8:	b8 05 00 00 00       	mov    $0x5,%eax
 2ed:	cd 40                	int    $0x40
 2ef:	c3                   	ret    

000002f0 <write>:
SYSCALL(write)
 2f0:	b8 10 00 00 00       	mov    $0x10,%eax
 2f5:	cd 40                	int    $0x40
 2f7:	c3                   	ret    

000002f8 <close>:
SYSCALL(close)
 2f8:	b8 15 00 00 00       	mov    $0x15,%eax
 2fd:	cd 40                	int    $0x40
 2ff:	c3                   	ret    

00000300 <kill>:
SYSCALL(kill)
 300:	b8 06 00 00 00       	mov    $0x6,%eax
 305:	cd 40                	int    $0x40
 307:	c3                   	ret    

00000308 <exec>:
SYSCALL(exec)
 308:	b8 07 00 00 00       	mov    $0x7,%eax
 30d:	cd 40                	int    $0x40
 30f:	c3                   	ret    

00000310 <open>:
SYSCALL(open)
 310:	b8 0f 00 00 00       	mov    $0xf,%eax
 315:	cd 40                	int    $0x40
 317:	c3                   	ret    

00000318 <mknod>:
SYSCALL(mknod)
 318:	b8 11 00 00 00       	mov    $0x11,%eax
 31d:	cd 40                	int    $0x40
 31f:	c3                   	ret    

00000320 <unlink>:
SYSCALL(unlink)
 320:	b8 12 00 00 00       	mov    $0x12,%eax
 325:	cd 40                	int    $0x40
 327:	c3                   	ret    

00000328 <fstat>:
SYSCALL(fstat)
 328:	b8 08 00 00 00       	mov    $0x8,%eax
 32d:	cd 40                	int    $0x40
 32f:	c3                   	ret    

00000330 <link>:
SYSCALL(link)
 330:	b8 13 00 00 00       	mov    $0x13,%eax
 335:	cd 40                	int    $0x40
 337:	c3                   	ret    

00000338 <mkdir>:
SYSCALL(mkdir)
 338:	b8 14 00 00 00       	mov    $0x14,%eax
 33d:	cd 40                	int    $0x40
 33f:	c3                   	ret    

00000340 <chdir>:
SYSCALL(chdir)
 340:	b8 09 00 00 00       	mov    $0x9,%eax
 345:	cd 40                	int    $0x40
 347:	c3                   	ret    

00000348 <dup>:
SYSCALL(dup)
 348:	b8 0a 00 00 00       	mov    $0xa,%eax
 34d:	cd 40                	int    $0x40
 34f:	c3                   	ret    

00000350 <getpid>:
SYSCALL(getpid)
 350:	b8 0b 00 00 00       	mov    $0xb,%eax
 355:	cd 40                	int    $0x40
 357:	c3                   	ret    

00000358 <sbrk>:
SYSCALL(sbrk)
 358:	b8 0c 00 00 00       	mov    $0xc,%eax
 35d:	cd 40                	int    $0x40
 35f:	c3                   	ret    

00000360 <sleep>:
SYSCALL(sleep)
 360:	b8 0d 00 00 00       	mov    $0xd,%eax
 365:	cd 40                	int    $0x40
 367:	c3                   	ret    

00000368 <uptime>:
SYSCALL(uptime)
 368:	b8 0e 00 00 00       	mov    $0xe,%eax
 36d:	cd 40                	int    $0x40
 36f:	c3                   	ret    

00000370 <mygetpid>:
SYSCALL(mygetpid)
 370:	b8 16 00 00 00       	mov    $0x16,%eax
 375:	cd 40                	int    $0x40
 377:	c3                   	ret    

00000378 <halt>:
SYSCALL(halt)
 378:	b8 17 00 00 00       	mov    $0x17,%eax
 37d:	cd 40                	int    $0x40
 37f:	c3                   	ret    

00000380 <pipe_count>:
SYSCALL(pipe_count)
 380:	b8 18 00 00 00       	mov    $0x18,%eax
 385:	cd 40                	int    $0x40
 387:	c3                   	ret    

00000388 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 388:	55                   	push   %ebp
 389:	89 e5                	mov    %esp,%ebp
 38b:	83 ec 18             	sub    $0x18,%esp
 38e:	8b 45 0c             	mov    0xc(%ebp),%eax
 391:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 394:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 39b:	00 
 39c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 39f:	89 44 24 04          	mov    %eax,0x4(%esp)
 3a3:	8b 45 08             	mov    0x8(%ebp),%eax
 3a6:	89 04 24             	mov    %eax,(%esp)
 3a9:	e8 42 ff ff ff       	call   2f0 <write>
}
 3ae:	c9                   	leave  
 3af:	c3                   	ret    

000003b0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3b0:	55                   	push   %ebp
 3b1:	89 e5                	mov    %esp,%ebp
 3b3:	56                   	push   %esi
 3b4:	53                   	push   %ebx
 3b5:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3b8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3bf:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3c3:	74 17                	je     3dc <printint+0x2c>
 3c5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3c9:	79 11                	jns    3dc <printint+0x2c>
    neg = 1;
 3cb:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3d2:	8b 45 0c             	mov    0xc(%ebp),%eax
 3d5:	f7 d8                	neg    %eax
 3d7:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3da:	eb 06                	jmp    3e2 <printint+0x32>
  } else {
    x = xx;
 3dc:	8b 45 0c             	mov    0xc(%ebp),%eax
 3df:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3e2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 3e9:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 3ec:	8d 41 01             	lea    0x1(%ecx),%eax
 3ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
 3f2:	8b 5d 10             	mov    0x10(%ebp),%ebx
 3f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3f8:	ba 00 00 00 00       	mov    $0x0,%edx
 3fd:	f7 f3                	div    %ebx
 3ff:	89 d0                	mov    %edx,%eax
 401:	8a 80 a0 0a 00 00    	mov    0xaa0(%eax),%al
 407:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 40b:	8b 75 10             	mov    0x10(%ebp),%esi
 40e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 411:	ba 00 00 00 00       	mov    $0x0,%edx
 416:	f7 f6                	div    %esi
 418:	89 45 ec             	mov    %eax,-0x14(%ebp)
 41b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 41f:	75 c8                	jne    3e9 <printint+0x39>
  if(neg)
 421:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 425:	74 10                	je     437 <printint+0x87>
    buf[i++] = '-';
 427:	8b 45 f4             	mov    -0xc(%ebp),%eax
 42a:	8d 50 01             	lea    0x1(%eax),%edx
 42d:	89 55 f4             	mov    %edx,-0xc(%ebp)
 430:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 435:	eb 1e                	jmp    455 <printint+0xa5>
 437:	eb 1c                	jmp    455 <printint+0xa5>
    putc(fd, buf[i]);
 439:	8d 55 dc             	lea    -0x24(%ebp),%edx
 43c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 43f:	01 d0                	add    %edx,%eax
 441:	8a 00                	mov    (%eax),%al
 443:	0f be c0             	movsbl %al,%eax
 446:	89 44 24 04          	mov    %eax,0x4(%esp)
 44a:	8b 45 08             	mov    0x8(%ebp),%eax
 44d:	89 04 24             	mov    %eax,(%esp)
 450:	e8 33 ff ff ff       	call   388 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 455:	ff 4d f4             	decl   -0xc(%ebp)
 458:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 45c:	79 db                	jns    439 <printint+0x89>
    putc(fd, buf[i]);
}
 45e:	83 c4 30             	add    $0x30,%esp
 461:	5b                   	pop    %ebx
 462:	5e                   	pop    %esi
 463:	5d                   	pop    %ebp
 464:	c3                   	ret    

00000465 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 465:	55                   	push   %ebp
 466:	89 e5                	mov    %esp,%ebp
 468:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 46b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 472:	8d 45 0c             	lea    0xc(%ebp),%eax
 475:	83 c0 04             	add    $0x4,%eax
 478:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 47b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 482:	e9 77 01 00 00       	jmp    5fe <printf+0x199>
    c = fmt[i] & 0xff;
 487:	8b 55 0c             	mov    0xc(%ebp),%edx
 48a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 48d:	01 d0                	add    %edx,%eax
 48f:	8a 00                	mov    (%eax),%al
 491:	0f be c0             	movsbl %al,%eax
 494:	25 ff 00 00 00       	and    $0xff,%eax
 499:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 49c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4a0:	75 2c                	jne    4ce <printf+0x69>
      if(c == '%'){
 4a2:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4a6:	75 0c                	jne    4b4 <printf+0x4f>
        state = '%';
 4a8:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 4af:	e9 47 01 00 00       	jmp    5fb <printf+0x196>
      } else {
        putc(fd, c);
 4b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4b7:	0f be c0             	movsbl %al,%eax
 4ba:	89 44 24 04          	mov    %eax,0x4(%esp)
 4be:	8b 45 08             	mov    0x8(%ebp),%eax
 4c1:	89 04 24             	mov    %eax,(%esp)
 4c4:	e8 bf fe ff ff       	call   388 <putc>
 4c9:	e9 2d 01 00 00       	jmp    5fb <printf+0x196>
      }
    } else if(state == '%'){
 4ce:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4d2:	0f 85 23 01 00 00    	jne    5fb <printf+0x196>
      if(c == 'd'){
 4d8:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4dc:	75 2d                	jne    50b <printf+0xa6>
        printint(fd, *ap, 10, 1);
 4de:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4e1:	8b 00                	mov    (%eax),%eax
 4e3:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 4ea:	00 
 4eb:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 4f2:	00 
 4f3:	89 44 24 04          	mov    %eax,0x4(%esp)
 4f7:	8b 45 08             	mov    0x8(%ebp),%eax
 4fa:	89 04 24             	mov    %eax,(%esp)
 4fd:	e8 ae fe ff ff       	call   3b0 <printint>
        ap++;
 502:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 506:	e9 e9 00 00 00       	jmp    5f4 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 50b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 50f:	74 06                	je     517 <printf+0xb2>
 511:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 515:	75 2d                	jne    544 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 517:	8b 45 e8             	mov    -0x18(%ebp),%eax
 51a:	8b 00                	mov    (%eax),%eax
 51c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 523:	00 
 524:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 52b:	00 
 52c:	89 44 24 04          	mov    %eax,0x4(%esp)
 530:	8b 45 08             	mov    0x8(%ebp),%eax
 533:	89 04 24             	mov    %eax,(%esp)
 536:	e8 75 fe ff ff       	call   3b0 <printint>
        ap++;
 53b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 53f:	e9 b0 00 00 00       	jmp    5f4 <printf+0x18f>
      } else if(c == 's'){
 544:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 548:	75 42                	jne    58c <printf+0x127>
        s = (char*)*ap;
 54a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 54d:	8b 00                	mov    (%eax),%eax
 54f:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 552:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 556:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 55a:	75 09                	jne    565 <printf+0x100>
          s = "(null)";
 55c:	c7 45 f4 52 08 00 00 	movl   $0x852,-0xc(%ebp)
        while(*s != 0){
 563:	eb 1c                	jmp    581 <printf+0x11c>
 565:	eb 1a                	jmp    581 <printf+0x11c>
          putc(fd, *s);
 567:	8b 45 f4             	mov    -0xc(%ebp),%eax
 56a:	8a 00                	mov    (%eax),%al
 56c:	0f be c0             	movsbl %al,%eax
 56f:	89 44 24 04          	mov    %eax,0x4(%esp)
 573:	8b 45 08             	mov    0x8(%ebp),%eax
 576:	89 04 24             	mov    %eax,(%esp)
 579:	e8 0a fe ff ff       	call   388 <putc>
          s++;
 57e:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 581:	8b 45 f4             	mov    -0xc(%ebp),%eax
 584:	8a 00                	mov    (%eax),%al
 586:	84 c0                	test   %al,%al
 588:	75 dd                	jne    567 <printf+0x102>
 58a:	eb 68                	jmp    5f4 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 58c:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 590:	75 1d                	jne    5af <printf+0x14a>
        putc(fd, *ap);
 592:	8b 45 e8             	mov    -0x18(%ebp),%eax
 595:	8b 00                	mov    (%eax),%eax
 597:	0f be c0             	movsbl %al,%eax
 59a:	89 44 24 04          	mov    %eax,0x4(%esp)
 59e:	8b 45 08             	mov    0x8(%ebp),%eax
 5a1:	89 04 24             	mov    %eax,(%esp)
 5a4:	e8 df fd ff ff       	call   388 <putc>
        ap++;
 5a9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5ad:	eb 45                	jmp    5f4 <printf+0x18f>
      } else if(c == '%'){
 5af:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5b3:	75 17                	jne    5cc <printf+0x167>
        putc(fd, c);
 5b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5b8:	0f be c0             	movsbl %al,%eax
 5bb:	89 44 24 04          	mov    %eax,0x4(%esp)
 5bf:	8b 45 08             	mov    0x8(%ebp),%eax
 5c2:	89 04 24             	mov    %eax,(%esp)
 5c5:	e8 be fd ff ff       	call   388 <putc>
 5ca:	eb 28                	jmp    5f4 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5cc:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 5d3:	00 
 5d4:	8b 45 08             	mov    0x8(%ebp),%eax
 5d7:	89 04 24             	mov    %eax,(%esp)
 5da:	e8 a9 fd ff ff       	call   388 <putc>
        putc(fd, c);
 5df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5e2:	0f be c0             	movsbl %al,%eax
 5e5:	89 44 24 04          	mov    %eax,0x4(%esp)
 5e9:	8b 45 08             	mov    0x8(%ebp),%eax
 5ec:	89 04 24             	mov    %eax,(%esp)
 5ef:	e8 94 fd ff ff       	call   388 <putc>
      }
      state = 0;
 5f4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 5fb:	ff 45 f0             	incl   -0x10(%ebp)
 5fe:	8b 55 0c             	mov    0xc(%ebp),%edx
 601:	8b 45 f0             	mov    -0x10(%ebp),%eax
 604:	01 d0                	add    %edx,%eax
 606:	8a 00                	mov    (%eax),%al
 608:	84 c0                	test   %al,%al
 60a:	0f 85 77 fe ff ff    	jne    487 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 610:	c9                   	leave  
 611:	c3                   	ret    
 612:	90                   	nop
 613:	90                   	nop

00000614 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 614:	55                   	push   %ebp
 615:	89 e5                	mov    %esp,%ebp
 617:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 61a:	8b 45 08             	mov    0x8(%ebp),%eax
 61d:	83 e8 08             	sub    $0x8,%eax
 620:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 623:	a1 bc 0a 00 00       	mov    0xabc,%eax
 628:	89 45 fc             	mov    %eax,-0x4(%ebp)
 62b:	eb 24                	jmp    651 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 62d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 630:	8b 00                	mov    (%eax),%eax
 632:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 635:	77 12                	ja     649 <free+0x35>
 637:	8b 45 f8             	mov    -0x8(%ebp),%eax
 63a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 63d:	77 24                	ja     663 <free+0x4f>
 63f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 642:	8b 00                	mov    (%eax),%eax
 644:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 647:	77 1a                	ja     663 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 649:	8b 45 fc             	mov    -0x4(%ebp),%eax
 64c:	8b 00                	mov    (%eax),%eax
 64e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 651:	8b 45 f8             	mov    -0x8(%ebp),%eax
 654:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 657:	76 d4                	jbe    62d <free+0x19>
 659:	8b 45 fc             	mov    -0x4(%ebp),%eax
 65c:	8b 00                	mov    (%eax),%eax
 65e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 661:	76 ca                	jbe    62d <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 663:	8b 45 f8             	mov    -0x8(%ebp),%eax
 666:	8b 40 04             	mov    0x4(%eax),%eax
 669:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 670:	8b 45 f8             	mov    -0x8(%ebp),%eax
 673:	01 c2                	add    %eax,%edx
 675:	8b 45 fc             	mov    -0x4(%ebp),%eax
 678:	8b 00                	mov    (%eax),%eax
 67a:	39 c2                	cmp    %eax,%edx
 67c:	75 24                	jne    6a2 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 67e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 681:	8b 50 04             	mov    0x4(%eax),%edx
 684:	8b 45 fc             	mov    -0x4(%ebp),%eax
 687:	8b 00                	mov    (%eax),%eax
 689:	8b 40 04             	mov    0x4(%eax),%eax
 68c:	01 c2                	add    %eax,%edx
 68e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 691:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 694:	8b 45 fc             	mov    -0x4(%ebp),%eax
 697:	8b 00                	mov    (%eax),%eax
 699:	8b 10                	mov    (%eax),%edx
 69b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 69e:	89 10                	mov    %edx,(%eax)
 6a0:	eb 0a                	jmp    6ac <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 6a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a5:	8b 10                	mov    (%eax),%edx
 6a7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6aa:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 6ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6af:	8b 40 04             	mov    0x4(%eax),%eax
 6b2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6bc:	01 d0                	add    %edx,%eax
 6be:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6c1:	75 20                	jne    6e3 <free+0xcf>
    p->s.size += bp->s.size;
 6c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c6:	8b 50 04             	mov    0x4(%eax),%edx
 6c9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6cc:	8b 40 04             	mov    0x4(%eax),%eax
 6cf:	01 c2                	add    %eax,%edx
 6d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d4:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6d7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6da:	8b 10                	mov    (%eax),%edx
 6dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6df:	89 10                	mov    %edx,(%eax)
 6e1:	eb 08                	jmp    6eb <free+0xd7>
  } else
    p->s.ptr = bp;
 6e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e6:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6e9:	89 10                	mov    %edx,(%eax)
  freep = p;
 6eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ee:	a3 bc 0a 00 00       	mov    %eax,0xabc
}
 6f3:	c9                   	leave  
 6f4:	c3                   	ret    

000006f5 <morecore>:

static Header*
morecore(uint nu)
{
 6f5:	55                   	push   %ebp
 6f6:	89 e5                	mov    %esp,%ebp
 6f8:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 6fb:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 702:	77 07                	ja     70b <morecore+0x16>
    nu = 4096;
 704:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 70b:	8b 45 08             	mov    0x8(%ebp),%eax
 70e:	c1 e0 03             	shl    $0x3,%eax
 711:	89 04 24             	mov    %eax,(%esp)
 714:	e8 3f fc ff ff       	call   358 <sbrk>
 719:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 71c:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 720:	75 07                	jne    729 <morecore+0x34>
    return 0;
 722:	b8 00 00 00 00       	mov    $0x0,%eax
 727:	eb 22                	jmp    74b <morecore+0x56>
  hp = (Header*)p;
 729:	8b 45 f4             	mov    -0xc(%ebp),%eax
 72c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 72f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 732:	8b 55 08             	mov    0x8(%ebp),%edx
 735:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 738:	8b 45 f0             	mov    -0x10(%ebp),%eax
 73b:	83 c0 08             	add    $0x8,%eax
 73e:	89 04 24             	mov    %eax,(%esp)
 741:	e8 ce fe ff ff       	call   614 <free>
  return freep;
 746:	a1 bc 0a 00 00       	mov    0xabc,%eax
}
 74b:	c9                   	leave  
 74c:	c3                   	ret    

0000074d <malloc>:

void*
malloc(uint nbytes)
{
 74d:	55                   	push   %ebp
 74e:	89 e5                	mov    %esp,%ebp
 750:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 753:	8b 45 08             	mov    0x8(%ebp),%eax
 756:	83 c0 07             	add    $0x7,%eax
 759:	c1 e8 03             	shr    $0x3,%eax
 75c:	40                   	inc    %eax
 75d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 760:	a1 bc 0a 00 00       	mov    0xabc,%eax
 765:	89 45 f0             	mov    %eax,-0x10(%ebp)
 768:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 76c:	75 23                	jne    791 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 76e:	c7 45 f0 b4 0a 00 00 	movl   $0xab4,-0x10(%ebp)
 775:	8b 45 f0             	mov    -0x10(%ebp),%eax
 778:	a3 bc 0a 00 00       	mov    %eax,0xabc
 77d:	a1 bc 0a 00 00       	mov    0xabc,%eax
 782:	a3 b4 0a 00 00       	mov    %eax,0xab4
    base.s.size = 0;
 787:	c7 05 b8 0a 00 00 00 	movl   $0x0,0xab8
 78e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 791:	8b 45 f0             	mov    -0x10(%ebp),%eax
 794:	8b 00                	mov    (%eax),%eax
 796:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 799:	8b 45 f4             	mov    -0xc(%ebp),%eax
 79c:	8b 40 04             	mov    0x4(%eax),%eax
 79f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7a2:	72 4d                	jb     7f1 <malloc+0xa4>
      if(p->s.size == nunits)
 7a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a7:	8b 40 04             	mov    0x4(%eax),%eax
 7aa:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7ad:	75 0c                	jne    7bb <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 7af:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b2:	8b 10                	mov    (%eax),%edx
 7b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7b7:	89 10                	mov    %edx,(%eax)
 7b9:	eb 26                	jmp    7e1 <malloc+0x94>
      else {
        p->s.size -= nunits;
 7bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7be:	8b 40 04             	mov    0x4(%eax),%eax
 7c1:	2b 45 ec             	sub    -0x14(%ebp),%eax
 7c4:	89 c2                	mov    %eax,%edx
 7c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c9:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7cf:	8b 40 04             	mov    0x4(%eax),%eax
 7d2:	c1 e0 03             	shl    $0x3,%eax
 7d5:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7db:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7de:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7e4:	a3 bc 0a 00 00       	mov    %eax,0xabc
      return (void*)(p + 1);
 7e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ec:	83 c0 08             	add    $0x8,%eax
 7ef:	eb 38                	jmp    829 <malloc+0xdc>
    }
    if(p == freep)
 7f1:	a1 bc 0a 00 00       	mov    0xabc,%eax
 7f6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 7f9:	75 1b                	jne    816 <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 7fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
 7fe:	89 04 24             	mov    %eax,(%esp)
 801:	e8 ef fe ff ff       	call   6f5 <morecore>
 806:	89 45 f4             	mov    %eax,-0xc(%ebp)
 809:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 80d:	75 07                	jne    816 <malloc+0xc9>
        return 0;
 80f:	b8 00 00 00 00       	mov    $0x0,%eax
 814:	eb 13                	jmp    829 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 816:	8b 45 f4             	mov    -0xc(%ebp),%eax
 819:	89 45 f0             	mov    %eax,-0x10(%ebp)
 81c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 81f:	8b 00                	mov    (%eax),%eax
 821:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 824:	e9 70 ff ff ff       	jmp    799 <malloc+0x4c>
}
 829:	c9                   	leave  
 82a:	c3                   	ret    
