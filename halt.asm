
_halt:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "types.h" 
#include "stat.h" 
#include "user.h" 

int main(int argc, char *argv[]) 
{ 
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
    halt(); 
   6:	e8 01 03 00 00       	call   30c <halt>
    exit(); 
   b:	e8 54 02 00 00       	call   264 <exit>

00000010 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  10:	55                   	push   %ebp
  11:	89 e5                	mov    %esp,%ebp
  13:	57                   	push   %edi
  14:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  15:	8b 4d 08             	mov    0x8(%ebp),%ecx
  18:	8b 55 10             	mov    0x10(%ebp),%edx
  1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  1e:	89 cb                	mov    %ecx,%ebx
  20:	89 df                	mov    %ebx,%edi
  22:	89 d1                	mov    %edx,%ecx
  24:	fc                   	cld    
  25:	f3 aa                	rep stos %al,%es:(%edi)
  27:	89 ca                	mov    %ecx,%edx
  29:	89 fb                	mov    %edi,%ebx
  2b:	89 5d 08             	mov    %ebx,0x8(%ebp)
  2e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  31:	5b                   	pop    %ebx
  32:	5f                   	pop    %edi
  33:	5d                   	pop    %ebp
  34:	c3                   	ret    

00000035 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  35:	55                   	push   %ebp
  36:	89 e5                	mov    %esp,%ebp
  38:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  3b:	8b 45 08             	mov    0x8(%ebp),%eax
  3e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  41:	90                   	nop
  42:	8b 45 08             	mov    0x8(%ebp),%eax
  45:	8d 50 01             	lea    0x1(%eax),%edx
  48:	89 55 08             	mov    %edx,0x8(%ebp)
  4b:	8b 55 0c             	mov    0xc(%ebp),%edx
  4e:	8d 4a 01             	lea    0x1(%edx),%ecx
  51:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  54:	8a 12                	mov    (%edx),%dl
  56:	88 10                	mov    %dl,(%eax)
  58:	8a 00                	mov    (%eax),%al
  5a:	84 c0                	test   %al,%al
  5c:	75 e4                	jne    42 <strcpy+0xd>
    ;
  return os;
  5e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  61:	c9                   	leave  
  62:	c3                   	ret    

00000063 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  63:	55                   	push   %ebp
  64:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  66:	eb 06                	jmp    6e <strcmp+0xb>
    p++, q++;
  68:	ff 45 08             	incl   0x8(%ebp)
  6b:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  6e:	8b 45 08             	mov    0x8(%ebp),%eax
  71:	8a 00                	mov    (%eax),%al
  73:	84 c0                	test   %al,%al
  75:	74 0e                	je     85 <strcmp+0x22>
  77:	8b 45 08             	mov    0x8(%ebp),%eax
  7a:	8a 10                	mov    (%eax),%dl
  7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  7f:	8a 00                	mov    (%eax),%al
  81:	38 c2                	cmp    %al,%dl
  83:	74 e3                	je     68 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  85:	8b 45 08             	mov    0x8(%ebp),%eax
  88:	8a 00                	mov    (%eax),%al
  8a:	0f b6 d0             	movzbl %al,%edx
  8d:	8b 45 0c             	mov    0xc(%ebp),%eax
  90:	8a 00                	mov    (%eax),%al
  92:	0f b6 c0             	movzbl %al,%eax
  95:	29 c2                	sub    %eax,%edx
  97:	89 d0                	mov    %edx,%eax
}
  99:	5d                   	pop    %ebp
  9a:	c3                   	ret    

0000009b <strlen>:

uint
strlen(char *s)
{
  9b:	55                   	push   %ebp
  9c:	89 e5                	mov    %esp,%ebp
  9e:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
  a1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  a8:	eb 03                	jmp    ad <strlen+0x12>
  aa:	ff 45 fc             	incl   -0x4(%ebp)
  ad:	8b 55 fc             	mov    -0x4(%ebp),%edx
  b0:	8b 45 08             	mov    0x8(%ebp),%eax
  b3:	01 d0                	add    %edx,%eax
  b5:	8a 00                	mov    (%eax),%al
  b7:	84 c0                	test   %al,%al
  b9:	75 ef                	jne    aa <strlen+0xf>
    ;
  return n;
  bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  be:	c9                   	leave  
  bf:	c3                   	ret    

000000c0 <memset>:

void*
memset(void *dst, int c, uint n)
{
  c0:	55                   	push   %ebp
  c1:	89 e5                	mov    %esp,%ebp
  c3:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
  c6:	8b 45 10             	mov    0x10(%ebp),%eax
  c9:	89 44 24 08          	mov    %eax,0x8(%esp)
  cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  d4:	8b 45 08             	mov    0x8(%ebp),%eax
  d7:	89 04 24             	mov    %eax,(%esp)
  da:	e8 31 ff ff ff       	call   10 <stosb>
  return dst;
  df:	8b 45 08             	mov    0x8(%ebp),%eax
}
  e2:	c9                   	leave  
  e3:	c3                   	ret    

000000e4 <strchr>:

char*
strchr(const char *s, char c)
{
  e4:	55                   	push   %ebp
  e5:	89 e5                	mov    %esp,%ebp
  e7:	83 ec 04             	sub    $0x4,%esp
  ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  ed:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
  f0:	eb 12                	jmp    104 <strchr+0x20>
    if(*s == c)
  f2:	8b 45 08             	mov    0x8(%ebp),%eax
  f5:	8a 00                	mov    (%eax),%al
  f7:	3a 45 fc             	cmp    -0x4(%ebp),%al
  fa:	75 05                	jne    101 <strchr+0x1d>
      return (char*)s;
  fc:	8b 45 08             	mov    0x8(%ebp),%eax
  ff:	eb 11                	jmp    112 <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 101:	ff 45 08             	incl   0x8(%ebp)
 104:	8b 45 08             	mov    0x8(%ebp),%eax
 107:	8a 00                	mov    (%eax),%al
 109:	84 c0                	test   %al,%al
 10b:	75 e5                	jne    f2 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 10d:	b8 00 00 00 00       	mov    $0x0,%eax
}
 112:	c9                   	leave  
 113:	c3                   	ret    

00000114 <gets>:

char*
gets(char *buf, int max)
{
 114:	55                   	push   %ebp
 115:	89 e5                	mov    %esp,%ebp
 117:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 11a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 121:	eb 49                	jmp    16c <gets+0x58>
    cc = read(0, &c, 1);
 123:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 12a:	00 
 12b:	8d 45 ef             	lea    -0x11(%ebp),%eax
 12e:	89 44 24 04          	mov    %eax,0x4(%esp)
 132:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 139:	e8 3e 01 00 00       	call   27c <read>
 13e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 141:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 145:	7f 02                	jg     149 <gets+0x35>
      break;
 147:	eb 2c                	jmp    175 <gets+0x61>
    buf[i++] = c;
 149:	8b 45 f4             	mov    -0xc(%ebp),%eax
 14c:	8d 50 01             	lea    0x1(%eax),%edx
 14f:	89 55 f4             	mov    %edx,-0xc(%ebp)
 152:	89 c2                	mov    %eax,%edx
 154:	8b 45 08             	mov    0x8(%ebp),%eax
 157:	01 c2                	add    %eax,%edx
 159:	8a 45 ef             	mov    -0x11(%ebp),%al
 15c:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 15e:	8a 45 ef             	mov    -0x11(%ebp),%al
 161:	3c 0a                	cmp    $0xa,%al
 163:	74 10                	je     175 <gets+0x61>
 165:	8a 45 ef             	mov    -0x11(%ebp),%al
 168:	3c 0d                	cmp    $0xd,%al
 16a:	74 09                	je     175 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 16c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 16f:	40                   	inc    %eax
 170:	3b 45 0c             	cmp    0xc(%ebp),%eax
 173:	7c ae                	jl     123 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 175:	8b 55 f4             	mov    -0xc(%ebp),%edx
 178:	8b 45 08             	mov    0x8(%ebp),%eax
 17b:	01 d0                	add    %edx,%eax
 17d:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 180:	8b 45 08             	mov    0x8(%ebp),%eax
}
 183:	c9                   	leave  
 184:	c3                   	ret    

00000185 <stat>:

int
stat(char *n, struct stat *st)
{
 185:	55                   	push   %ebp
 186:	89 e5                	mov    %esp,%ebp
 188:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 18b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 192:	00 
 193:	8b 45 08             	mov    0x8(%ebp),%eax
 196:	89 04 24             	mov    %eax,(%esp)
 199:	e8 06 01 00 00       	call   2a4 <open>
 19e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 1a1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 1a5:	79 07                	jns    1ae <stat+0x29>
    return -1;
 1a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 1ac:	eb 23                	jmp    1d1 <stat+0x4c>
  r = fstat(fd, st);
 1ae:	8b 45 0c             	mov    0xc(%ebp),%eax
 1b1:	89 44 24 04          	mov    %eax,0x4(%esp)
 1b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1b8:	89 04 24             	mov    %eax,(%esp)
 1bb:	e8 fc 00 00 00       	call   2bc <fstat>
 1c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 1c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1c6:	89 04 24             	mov    %eax,(%esp)
 1c9:	e8 be 00 00 00       	call   28c <close>
  return r;
 1ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 1d1:	c9                   	leave  
 1d2:	c3                   	ret    

000001d3 <atoi>:

int
atoi(const char *s)
{
 1d3:	55                   	push   %ebp
 1d4:	89 e5                	mov    %esp,%ebp
 1d6:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 1d9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 1e0:	eb 24                	jmp    206 <atoi+0x33>
    n = n*10 + *s++ - '0';
 1e2:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1e5:	89 d0                	mov    %edx,%eax
 1e7:	c1 e0 02             	shl    $0x2,%eax
 1ea:	01 d0                	add    %edx,%eax
 1ec:	01 c0                	add    %eax,%eax
 1ee:	89 c1                	mov    %eax,%ecx
 1f0:	8b 45 08             	mov    0x8(%ebp),%eax
 1f3:	8d 50 01             	lea    0x1(%eax),%edx
 1f6:	89 55 08             	mov    %edx,0x8(%ebp)
 1f9:	8a 00                	mov    (%eax),%al
 1fb:	0f be c0             	movsbl %al,%eax
 1fe:	01 c8                	add    %ecx,%eax
 200:	83 e8 30             	sub    $0x30,%eax
 203:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 206:	8b 45 08             	mov    0x8(%ebp),%eax
 209:	8a 00                	mov    (%eax),%al
 20b:	3c 2f                	cmp    $0x2f,%al
 20d:	7e 09                	jle    218 <atoi+0x45>
 20f:	8b 45 08             	mov    0x8(%ebp),%eax
 212:	8a 00                	mov    (%eax),%al
 214:	3c 39                	cmp    $0x39,%al
 216:	7e ca                	jle    1e2 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 218:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 21b:	c9                   	leave  
 21c:	c3                   	ret    

0000021d <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 21d:	55                   	push   %ebp
 21e:	89 e5                	mov    %esp,%ebp
 220:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 223:	8b 45 08             	mov    0x8(%ebp),%eax
 226:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 229:	8b 45 0c             	mov    0xc(%ebp),%eax
 22c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 22f:	eb 16                	jmp    247 <memmove+0x2a>
    *dst++ = *src++;
 231:	8b 45 fc             	mov    -0x4(%ebp),%eax
 234:	8d 50 01             	lea    0x1(%eax),%edx
 237:	89 55 fc             	mov    %edx,-0x4(%ebp)
 23a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 23d:	8d 4a 01             	lea    0x1(%edx),%ecx
 240:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 243:	8a 12                	mov    (%edx),%dl
 245:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 247:	8b 45 10             	mov    0x10(%ebp),%eax
 24a:	8d 50 ff             	lea    -0x1(%eax),%edx
 24d:	89 55 10             	mov    %edx,0x10(%ebp)
 250:	85 c0                	test   %eax,%eax
 252:	7f dd                	jg     231 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 254:	8b 45 08             	mov    0x8(%ebp),%eax
}
 257:	c9                   	leave  
 258:	c3                   	ret    
 259:	90                   	nop
 25a:	90                   	nop
 25b:	90                   	nop

0000025c <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 25c:	b8 01 00 00 00       	mov    $0x1,%eax
 261:	cd 40                	int    $0x40
 263:	c3                   	ret    

00000264 <exit>:
SYSCALL(exit)
 264:	b8 02 00 00 00       	mov    $0x2,%eax
 269:	cd 40                	int    $0x40
 26b:	c3                   	ret    

0000026c <wait>:
SYSCALL(wait)
 26c:	b8 03 00 00 00       	mov    $0x3,%eax
 271:	cd 40                	int    $0x40
 273:	c3                   	ret    

00000274 <pipe>:
SYSCALL(pipe)
 274:	b8 04 00 00 00       	mov    $0x4,%eax
 279:	cd 40                	int    $0x40
 27b:	c3                   	ret    

0000027c <read>:
SYSCALL(read)
 27c:	b8 05 00 00 00       	mov    $0x5,%eax
 281:	cd 40                	int    $0x40
 283:	c3                   	ret    

00000284 <write>:
SYSCALL(write)
 284:	b8 10 00 00 00       	mov    $0x10,%eax
 289:	cd 40                	int    $0x40
 28b:	c3                   	ret    

0000028c <close>:
SYSCALL(close)
 28c:	b8 15 00 00 00       	mov    $0x15,%eax
 291:	cd 40                	int    $0x40
 293:	c3                   	ret    

00000294 <kill>:
SYSCALL(kill)
 294:	b8 06 00 00 00       	mov    $0x6,%eax
 299:	cd 40                	int    $0x40
 29b:	c3                   	ret    

0000029c <exec>:
SYSCALL(exec)
 29c:	b8 07 00 00 00       	mov    $0x7,%eax
 2a1:	cd 40                	int    $0x40
 2a3:	c3                   	ret    

000002a4 <open>:
SYSCALL(open)
 2a4:	b8 0f 00 00 00       	mov    $0xf,%eax
 2a9:	cd 40                	int    $0x40
 2ab:	c3                   	ret    

000002ac <mknod>:
SYSCALL(mknod)
 2ac:	b8 11 00 00 00       	mov    $0x11,%eax
 2b1:	cd 40                	int    $0x40
 2b3:	c3                   	ret    

000002b4 <unlink>:
SYSCALL(unlink)
 2b4:	b8 12 00 00 00       	mov    $0x12,%eax
 2b9:	cd 40                	int    $0x40
 2bb:	c3                   	ret    

000002bc <fstat>:
SYSCALL(fstat)
 2bc:	b8 08 00 00 00       	mov    $0x8,%eax
 2c1:	cd 40                	int    $0x40
 2c3:	c3                   	ret    

000002c4 <link>:
SYSCALL(link)
 2c4:	b8 13 00 00 00       	mov    $0x13,%eax
 2c9:	cd 40                	int    $0x40
 2cb:	c3                   	ret    

000002cc <mkdir>:
SYSCALL(mkdir)
 2cc:	b8 14 00 00 00       	mov    $0x14,%eax
 2d1:	cd 40                	int    $0x40
 2d3:	c3                   	ret    

000002d4 <chdir>:
SYSCALL(chdir)
 2d4:	b8 09 00 00 00       	mov    $0x9,%eax
 2d9:	cd 40                	int    $0x40
 2db:	c3                   	ret    

000002dc <dup>:
SYSCALL(dup)
 2dc:	b8 0a 00 00 00       	mov    $0xa,%eax
 2e1:	cd 40                	int    $0x40
 2e3:	c3                   	ret    

000002e4 <getpid>:
SYSCALL(getpid)
 2e4:	b8 0b 00 00 00       	mov    $0xb,%eax
 2e9:	cd 40                	int    $0x40
 2eb:	c3                   	ret    

000002ec <sbrk>:
SYSCALL(sbrk)
 2ec:	b8 0c 00 00 00       	mov    $0xc,%eax
 2f1:	cd 40                	int    $0x40
 2f3:	c3                   	ret    

000002f4 <sleep>:
SYSCALL(sleep)
 2f4:	b8 0d 00 00 00       	mov    $0xd,%eax
 2f9:	cd 40                	int    $0x40
 2fb:	c3                   	ret    

000002fc <uptime>:
SYSCALL(uptime)
 2fc:	b8 0e 00 00 00       	mov    $0xe,%eax
 301:	cd 40                	int    $0x40
 303:	c3                   	ret    

00000304 <mygetpid>:
SYSCALL(mygetpid)
 304:	b8 16 00 00 00       	mov    $0x16,%eax
 309:	cd 40                	int    $0x40
 30b:	c3                   	ret    

0000030c <halt>:
SYSCALL(halt)
 30c:	b8 17 00 00 00       	mov    $0x17,%eax
 311:	cd 40                	int    $0x40
 313:	c3                   	ret    

00000314 <pipe_count>:
SYSCALL(pipe_count)
 314:	b8 18 00 00 00       	mov    $0x18,%eax
 319:	cd 40                	int    $0x40
 31b:	c3                   	ret    

0000031c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 31c:	55                   	push   %ebp
 31d:	89 e5                	mov    %esp,%ebp
 31f:	83 ec 18             	sub    $0x18,%esp
 322:	8b 45 0c             	mov    0xc(%ebp),%eax
 325:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 328:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 32f:	00 
 330:	8d 45 f4             	lea    -0xc(%ebp),%eax
 333:	89 44 24 04          	mov    %eax,0x4(%esp)
 337:	8b 45 08             	mov    0x8(%ebp),%eax
 33a:	89 04 24             	mov    %eax,(%esp)
 33d:	e8 42 ff ff ff       	call   284 <write>
}
 342:	c9                   	leave  
 343:	c3                   	ret    

00000344 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 344:	55                   	push   %ebp
 345:	89 e5                	mov    %esp,%ebp
 347:	56                   	push   %esi
 348:	53                   	push   %ebx
 349:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 34c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 353:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 357:	74 17                	je     370 <printint+0x2c>
 359:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 35d:	79 11                	jns    370 <printint+0x2c>
    neg = 1;
 35f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 366:	8b 45 0c             	mov    0xc(%ebp),%eax
 369:	f7 d8                	neg    %eax
 36b:	89 45 ec             	mov    %eax,-0x14(%ebp)
 36e:	eb 06                	jmp    376 <printint+0x32>
  } else {
    x = xx;
 370:	8b 45 0c             	mov    0xc(%ebp),%eax
 373:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 376:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 37d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 380:	8d 41 01             	lea    0x1(%ecx),%eax
 383:	89 45 f4             	mov    %eax,-0xc(%ebp)
 386:	8b 5d 10             	mov    0x10(%ebp),%ebx
 389:	8b 45 ec             	mov    -0x14(%ebp),%eax
 38c:	ba 00 00 00 00       	mov    $0x0,%edx
 391:	f7 f3                	div    %ebx
 393:	89 d0                	mov    %edx,%eax
 395:	8a 80 0c 0a 00 00    	mov    0xa0c(%eax),%al
 39b:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 39f:	8b 75 10             	mov    0x10(%ebp),%esi
 3a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3a5:	ba 00 00 00 00       	mov    $0x0,%edx
 3aa:	f7 f6                	div    %esi
 3ac:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3af:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 3b3:	75 c8                	jne    37d <printint+0x39>
  if(neg)
 3b5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3b9:	74 10                	je     3cb <printint+0x87>
    buf[i++] = '-';
 3bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3be:	8d 50 01             	lea    0x1(%eax),%edx
 3c1:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3c4:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 3c9:	eb 1e                	jmp    3e9 <printint+0xa5>
 3cb:	eb 1c                	jmp    3e9 <printint+0xa5>
    putc(fd, buf[i]);
 3cd:	8d 55 dc             	lea    -0x24(%ebp),%edx
 3d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3d3:	01 d0                	add    %edx,%eax
 3d5:	8a 00                	mov    (%eax),%al
 3d7:	0f be c0             	movsbl %al,%eax
 3da:	89 44 24 04          	mov    %eax,0x4(%esp)
 3de:	8b 45 08             	mov    0x8(%ebp),%eax
 3e1:	89 04 24             	mov    %eax,(%esp)
 3e4:	e8 33 ff ff ff       	call   31c <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 3e9:	ff 4d f4             	decl   -0xc(%ebp)
 3ec:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 3f0:	79 db                	jns    3cd <printint+0x89>
    putc(fd, buf[i]);
}
 3f2:	83 c4 30             	add    $0x30,%esp
 3f5:	5b                   	pop    %ebx
 3f6:	5e                   	pop    %esi
 3f7:	5d                   	pop    %ebp
 3f8:	c3                   	ret    

000003f9 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 3f9:	55                   	push   %ebp
 3fa:	89 e5                	mov    %esp,%ebp
 3fc:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 3ff:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 406:	8d 45 0c             	lea    0xc(%ebp),%eax
 409:	83 c0 04             	add    $0x4,%eax
 40c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 40f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 416:	e9 77 01 00 00       	jmp    592 <printf+0x199>
    c = fmt[i] & 0xff;
 41b:	8b 55 0c             	mov    0xc(%ebp),%edx
 41e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 421:	01 d0                	add    %edx,%eax
 423:	8a 00                	mov    (%eax),%al
 425:	0f be c0             	movsbl %al,%eax
 428:	25 ff 00 00 00       	and    $0xff,%eax
 42d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 430:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 434:	75 2c                	jne    462 <printf+0x69>
      if(c == '%'){
 436:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 43a:	75 0c                	jne    448 <printf+0x4f>
        state = '%';
 43c:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 443:	e9 47 01 00 00       	jmp    58f <printf+0x196>
      } else {
        putc(fd, c);
 448:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 44b:	0f be c0             	movsbl %al,%eax
 44e:	89 44 24 04          	mov    %eax,0x4(%esp)
 452:	8b 45 08             	mov    0x8(%ebp),%eax
 455:	89 04 24             	mov    %eax,(%esp)
 458:	e8 bf fe ff ff       	call   31c <putc>
 45d:	e9 2d 01 00 00       	jmp    58f <printf+0x196>
      }
    } else if(state == '%'){
 462:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 466:	0f 85 23 01 00 00    	jne    58f <printf+0x196>
      if(c == 'd'){
 46c:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 470:	75 2d                	jne    49f <printf+0xa6>
        printint(fd, *ap, 10, 1);
 472:	8b 45 e8             	mov    -0x18(%ebp),%eax
 475:	8b 00                	mov    (%eax),%eax
 477:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 47e:	00 
 47f:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 486:	00 
 487:	89 44 24 04          	mov    %eax,0x4(%esp)
 48b:	8b 45 08             	mov    0x8(%ebp),%eax
 48e:	89 04 24             	mov    %eax,(%esp)
 491:	e8 ae fe ff ff       	call   344 <printint>
        ap++;
 496:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 49a:	e9 e9 00 00 00       	jmp    588 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 49f:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 4a3:	74 06                	je     4ab <printf+0xb2>
 4a5:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 4a9:	75 2d                	jne    4d8 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 4ab:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4ae:	8b 00                	mov    (%eax),%eax
 4b0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 4b7:	00 
 4b8:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 4bf:	00 
 4c0:	89 44 24 04          	mov    %eax,0x4(%esp)
 4c4:	8b 45 08             	mov    0x8(%ebp),%eax
 4c7:	89 04 24             	mov    %eax,(%esp)
 4ca:	e8 75 fe ff ff       	call   344 <printint>
        ap++;
 4cf:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4d3:	e9 b0 00 00 00       	jmp    588 <printf+0x18f>
      } else if(c == 's'){
 4d8:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 4dc:	75 42                	jne    520 <printf+0x127>
        s = (char*)*ap;
 4de:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4e1:	8b 00                	mov    (%eax),%eax
 4e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 4e6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 4ea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4ee:	75 09                	jne    4f9 <printf+0x100>
          s = "(null)";
 4f0:	c7 45 f4 bf 07 00 00 	movl   $0x7bf,-0xc(%ebp)
        while(*s != 0){
 4f7:	eb 1c                	jmp    515 <printf+0x11c>
 4f9:	eb 1a                	jmp    515 <printf+0x11c>
          putc(fd, *s);
 4fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4fe:	8a 00                	mov    (%eax),%al
 500:	0f be c0             	movsbl %al,%eax
 503:	89 44 24 04          	mov    %eax,0x4(%esp)
 507:	8b 45 08             	mov    0x8(%ebp),%eax
 50a:	89 04 24             	mov    %eax,(%esp)
 50d:	e8 0a fe ff ff       	call   31c <putc>
          s++;
 512:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 515:	8b 45 f4             	mov    -0xc(%ebp),%eax
 518:	8a 00                	mov    (%eax),%al
 51a:	84 c0                	test   %al,%al
 51c:	75 dd                	jne    4fb <printf+0x102>
 51e:	eb 68                	jmp    588 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 520:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 524:	75 1d                	jne    543 <printf+0x14a>
        putc(fd, *ap);
 526:	8b 45 e8             	mov    -0x18(%ebp),%eax
 529:	8b 00                	mov    (%eax),%eax
 52b:	0f be c0             	movsbl %al,%eax
 52e:	89 44 24 04          	mov    %eax,0x4(%esp)
 532:	8b 45 08             	mov    0x8(%ebp),%eax
 535:	89 04 24             	mov    %eax,(%esp)
 538:	e8 df fd ff ff       	call   31c <putc>
        ap++;
 53d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 541:	eb 45                	jmp    588 <printf+0x18f>
      } else if(c == '%'){
 543:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 547:	75 17                	jne    560 <printf+0x167>
        putc(fd, c);
 549:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 54c:	0f be c0             	movsbl %al,%eax
 54f:	89 44 24 04          	mov    %eax,0x4(%esp)
 553:	8b 45 08             	mov    0x8(%ebp),%eax
 556:	89 04 24             	mov    %eax,(%esp)
 559:	e8 be fd ff ff       	call   31c <putc>
 55e:	eb 28                	jmp    588 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 560:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 567:	00 
 568:	8b 45 08             	mov    0x8(%ebp),%eax
 56b:	89 04 24             	mov    %eax,(%esp)
 56e:	e8 a9 fd ff ff       	call   31c <putc>
        putc(fd, c);
 573:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 576:	0f be c0             	movsbl %al,%eax
 579:	89 44 24 04          	mov    %eax,0x4(%esp)
 57d:	8b 45 08             	mov    0x8(%ebp),%eax
 580:	89 04 24             	mov    %eax,(%esp)
 583:	e8 94 fd ff ff       	call   31c <putc>
      }
      state = 0;
 588:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 58f:	ff 45 f0             	incl   -0x10(%ebp)
 592:	8b 55 0c             	mov    0xc(%ebp),%edx
 595:	8b 45 f0             	mov    -0x10(%ebp),%eax
 598:	01 d0                	add    %edx,%eax
 59a:	8a 00                	mov    (%eax),%al
 59c:	84 c0                	test   %al,%al
 59e:	0f 85 77 fe ff ff    	jne    41b <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 5a4:	c9                   	leave  
 5a5:	c3                   	ret    
 5a6:	90                   	nop
 5a7:	90                   	nop

000005a8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5a8:	55                   	push   %ebp
 5a9:	89 e5                	mov    %esp,%ebp
 5ab:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5ae:	8b 45 08             	mov    0x8(%ebp),%eax
 5b1:	83 e8 08             	sub    $0x8,%eax
 5b4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5b7:	a1 28 0a 00 00       	mov    0xa28,%eax
 5bc:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5bf:	eb 24                	jmp    5e5 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5c4:	8b 00                	mov    (%eax),%eax
 5c6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5c9:	77 12                	ja     5dd <free+0x35>
 5cb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5ce:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5d1:	77 24                	ja     5f7 <free+0x4f>
 5d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5d6:	8b 00                	mov    (%eax),%eax
 5d8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 5db:	77 1a                	ja     5f7 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5e0:	8b 00                	mov    (%eax),%eax
 5e2:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5e5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5e8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5eb:	76 d4                	jbe    5c1 <free+0x19>
 5ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5f0:	8b 00                	mov    (%eax),%eax
 5f2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 5f5:	76 ca                	jbe    5c1 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 5f7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5fa:	8b 40 04             	mov    0x4(%eax),%eax
 5fd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 604:	8b 45 f8             	mov    -0x8(%ebp),%eax
 607:	01 c2                	add    %eax,%edx
 609:	8b 45 fc             	mov    -0x4(%ebp),%eax
 60c:	8b 00                	mov    (%eax),%eax
 60e:	39 c2                	cmp    %eax,%edx
 610:	75 24                	jne    636 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 612:	8b 45 f8             	mov    -0x8(%ebp),%eax
 615:	8b 50 04             	mov    0x4(%eax),%edx
 618:	8b 45 fc             	mov    -0x4(%ebp),%eax
 61b:	8b 00                	mov    (%eax),%eax
 61d:	8b 40 04             	mov    0x4(%eax),%eax
 620:	01 c2                	add    %eax,%edx
 622:	8b 45 f8             	mov    -0x8(%ebp),%eax
 625:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 628:	8b 45 fc             	mov    -0x4(%ebp),%eax
 62b:	8b 00                	mov    (%eax),%eax
 62d:	8b 10                	mov    (%eax),%edx
 62f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 632:	89 10                	mov    %edx,(%eax)
 634:	eb 0a                	jmp    640 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 636:	8b 45 fc             	mov    -0x4(%ebp),%eax
 639:	8b 10                	mov    (%eax),%edx
 63b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 63e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 640:	8b 45 fc             	mov    -0x4(%ebp),%eax
 643:	8b 40 04             	mov    0x4(%eax),%eax
 646:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 64d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 650:	01 d0                	add    %edx,%eax
 652:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 655:	75 20                	jne    677 <free+0xcf>
    p->s.size += bp->s.size;
 657:	8b 45 fc             	mov    -0x4(%ebp),%eax
 65a:	8b 50 04             	mov    0x4(%eax),%edx
 65d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 660:	8b 40 04             	mov    0x4(%eax),%eax
 663:	01 c2                	add    %eax,%edx
 665:	8b 45 fc             	mov    -0x4(%ebp),%eax
 668:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 66b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 66e:	8b 10                	mov    (%eax),%edx
 670:	8b 45 fc             	mov    -0x4(%ebp),%eax
 673:	89 10                	mov    %edx,(%eax)
 675:	eb 08                	jmp    67f <free+0xd7>
  } else
    p->s.ptr = bp;
 677:	8b 45 fc             	mov    -0x4(%ebp),%eax
 67a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 67d:	89 10                	mov    %edx,(%eax)
  freep = p;
 67f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 682:	a3 28 0a 00 00       	mov    %eax,0xa28
}
 687:	c9                   	leave  
 688:	c3                   	ret    

00000689 <morecore>:

static Header*
morecore(uint nu)
{
 689:	55                   	push   %ebp
 68a:	89 e5                	mov    %esp,%ebp
 68c:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 68f:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 696:	77 07                	ja     69f <morecore+0x16>
    nu = 4096;
 698:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 69f:	8b 45 08             	mov    0x8(%ebp),%eax
 6a2:	c1 e0 03             	shl    $0x3,%eax
 6a5:	89 04 24             	mov    %eax,(%esp)
 6a8:	e8 3f fc ff ff       	call   2ec <sbrk>
 6ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 6b0:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 6b4:	75 07                	jne    6bd <morecore+0x34>
    return 0;
 6b6:	b8 00 00 00 00       	mov    $0x0,%eax
 6bb:	eb 22                	jmp    6df <morecore+0x56>
  hp = (Header*)p;
 6bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 6c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6c6:	8b 55 08             	mov    0x8(%ebp),%edx
 6c9:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 6cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6cf:	83 c0 08             	add    $0x8,%eax
 6d2:	89 04 24             	mov    %eax,(%esp)
 6d5:	e8 ce fe ff ff       	call   5a8 <free>
  return freep;
 6da:	a1 28 0a 00 00       	mov    0xa28,%eax
}
 6df:	c9                   	leave  
 6e0:	c3                   	ret    

000006e1 <malloc>:

void*
malloc(uint nbytes)
{
 6e1:	55                   	push   %ebp
 6e2:	89 e5                	mov    %esp,%ebp
 6e4:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 6e7:	8b 45 08             	mov    0x8(%ebp),%eax
 6ea:	83 c0 07             	add    $0x7,%eax
 6ed:	c1 e8 03             	shr    $0x3,%eax
 6f0:	40                   	inc    %eax
 6f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 6f4:	a1 28 0a 00 00       	mov    0xa28,%eax
 6f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 6fc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 700:	75 23                	jne    725 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 702:	c7 45 f0 20 0a 00 00 	movl   $0xa20,-0x10(%ebp)
 709:	8b 45 f0             	mov    -0x10(%ebp),%eax
 70c:	a3 28 0a 00 00       	mov    %eax,0xa28
 711:	a1 28 0a 00 00       	mov    0xa28,%eax
 716:	a3 20 0a 00 00       	mov    %eax,0xa20
    base.s.size = 0;
 71b:	c7 05 24 0a 00 00 00 	movl   $0x0,0xa24
 722:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 725:	8b 45 f0             	mov    -0x10(%ebp),%eax
 728:	8b 00                	mov    (%eax),%eax
 72a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 72d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 730:	8b 40 04             	mov    0x4(%eax),%eax
 733:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 736:	72 4d                	jb     785 <malloc+0xa4>
      if(p->s.size == nunits)
 738:	8b 45 f4             	mov    -0xc(%ebp),%eax
 73b:	8b 40 04             	mov    0x4(%eax),%eax
 73e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 741:	75 0c                	jne    74f <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 743:	8b 45 f4             	mov    -0xc(%ebp),%eax
 746:	8b 10                	mov    (%eax),%edx
 748:	8b 45 f0             	mov    -0x10(%ebp),%eax
 74b:	89 10                	mov    %edx,(%eax)
 74d:	eb 26                	jmp    775 <malloc+0x94>
      else {
        p->s.size -= nunits;
 74f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 752:	8b 40 04             	mov    0x4(%eax),%eax
 755:	2b 45 ec             	sub    -0x14(%ebp),%eax
 758:	89 c2                	mov    %eax,%edx
 75a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 75d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 760:	8b 45 f4             	mov    -0xc(%ebp),%eax
 763:	8b 40 04             	mov    0x4(%eax),%eax
 766:	c1 e0 03             	shl    $0x3,%eax
 769:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 76c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 76f:	8b 55 ec             	mov    -0x14(%ebp),%edx
 772:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 775:	8b 45 f0             	mov    -0x10(%ebp),%eax
 778:	a3 28 0a 00 00       	mov    %eax,0xa28
      return (void*)(p + 1);
 77d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 780:	83 c0 08             	add    $0x8,%eax
 783:	eb 38                	jmp    7bd <malloc+0xdc>
    }
    if(p == freep)
 785:	a1 28 0a 00 00       	mov    0xa28,%eax
 78a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 78d:	75 1b                	jne    7aa <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 78f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 792:	89 04 24             	mov    %eax,(%esp)
 795:	e8 ef fe ff ff       	call   689 <morecore>
 79a:	89 45 f4             	mov    %eax,-0xc(%ebp)
 79d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7a1:	75 07                	jne    7aa <malloc+0xc9>
        return 0;
 7a3:	b8 00 00 00 00       	mov    $0x0,%eax
 7a8:	eb 13                	jmp    7bd <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b3:	8b 00                	mov    (%eax),%eax
 7b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 7b8:	e9 70 ff ff ff       	jmp    72d <malloc+0x4c>
}
 7bd:	c9                   	leave  
 7be:	c3                   	ret    
