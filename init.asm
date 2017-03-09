
_init:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:

char *argv[] = { "sh", 0 };

int
main(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 20             	sub    $0x20,%esp
  int pid, wpid;

  if(open("console", O_RDWR) < 0){
   9:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  10:	00 
  11:	c7 04 24 c2 08 00 00 	movl   $0x8c2,(%esp)
  18:	e8 87 03 00 00       	call   3a4 <open>
  1d:	85 c0                	test   %eax,%eax
  1f:	79 30                	jns    51 <main+0x51>
    mknod("console", 1, 1);
  21:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  28:	00 
  29:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  30:	00 
  31:	c7 04 24 c2 08 00 00 	movl   $0x8c2,(%esp)
  38:	e8 6f 03 00 00       	call   3ac <mknod>
    open("console", O_RDWR);
  3d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  44:	00 
  45:	c7 04 24 c2 08 00 00 	movl   $0x8c2,(%esp)
  4c:	e8 53 03 00 00       	call   3a4 <open>
  }
  dup(0);  // stdout
  51:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  58:	e8 7f 03 00 00       	call   3dc <dup>
  dup(0);  // stderr
  5d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  64:	e8 73 03 00 00       	call   3dc <dup>

  for(;;){
    printf(1, "init: starting sh\n");
  69:	c7 44 24 04 ca 08 00 	movl   $0x8ca,0x4(%esp)
  70:	00 
  71:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  78:	e8 7c 04 00 00       	call   4f9 <printf>
    pid = fork();
  7d:	e8 da 02 00 00       	call   35c <fork>
  82:	89 44 24 1c          	mov    %eax,0x1c(%esp)
    if(pid < 0){
  86:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
  8b:	79 19                	jns    a6 <main+0xa6>
      printf(1, "init: fork failed\n");
  8d:	c7 44 24 04 dd 08 00 	movl   $0x8dd,0x4(%esp)
  94:	00 
  95:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  9c:	e8 58 04 00 00       	call   4f9 <printf>
      exit();
  a1:	e8 be 02 00 00       	call   364 <exit>
    }
    if(pid == 0){
  a6:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
  ab:	75 2d                	jne    da <main+0xda>
      exec("sh", argv);
  ad:	c7 44 24 04 5c 0b 00 	movl   $0xb5c,0x4(%esp)
  b4:	00 
  b5:	c7 04 24 bf 08 00 00 	movl   $0x8bf,(%esp)
  bc:	e8 db 02 00 00       	call   39c <exec>
      printf(1, "init: exec sh failed\n");
  c1:	c7 44 24 04 f0 08 00 	movl   $0x8f0,0x4(%esp)
  c8:	00 
  c9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  d0:	e8 24 04 00 00       	call   4f9 <printf>
      exit();
  d5:	e8 8a 02 00 00       	call   364 <exit>
    }
    while((wpid=wait()) >= 0 && wpid != pid)
  da:	eb 14                	jmp    f0 <main+0xf0>
      printf(1, "zombie!\n");
  dc:	c7 44 24 04 06 09 00 	movl   $0x906,0x4(%esp)
  e3:	00 
  e4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  eb:	e8 09 04 00 00       	call   4f9 <printf>
    if(pid == 0){
      exec("sh", argv);
      printf(1, "init: exec sh failed\n");
      exit();
    }
    while((wpid=wait()) >= 0 && wpid != pid)
  f0:	e8 77 02 00 00       	call   36c <wait>
  f5:	89 44 24 18          	mov    %eax,0x18(%esp)
  f9:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
  fe:	78 0a                	js     10a <main+0x10a>
 100:	8b 44 24 18          	mov    0x18(%esp),%eax
 104:	3b 44 24 1c          	cmp    0x1c(%esp),%eax
 108:	75 d2                	jne    dc <main+0xdc>
      printf(1, "zombie!\n");
  }
 10a:	e9 5a ff ff ff       	jmp    69 <main+0x69>
 10f:	90                   	nop

00000110 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 110:	55                   	push   %ebp
 111:	89 e5                	mov    %esp,%ebp
 113:	57                   	push   %edi
 114:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 115:	8b 4d 08             	mov    0x8(%ebp),%ecx
 118:	8b 55 10             	mov    0x10(%ebp),%edx
 11b:	8b 45 0c             	mov    0xc(%ebp),%eax
 11e:	89 cb                	mov    %ecx,%ebx
 120:	89 df                	mov    %ebx,%edi
 122:	89 d1                	mov    %edx,%ecx
 124:	fc                   	cld    
 125:	f3 aa                	rep stos %al,%es:(%edi)
 127:	89 ca                	mov    %ecx,%edx
 129:	89 fb                	mov    %edi,%ebx
 12b:	89 5d 08             	mov    %ebx,0x8(%ebp)
 12e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 131:	5b                   	pop    %ebx
 132:	5f                   	pop    %edi
 133:	5d                   	pop    %ebp
 134:	c3                   	ret    

00000135 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 135:	55                   	push   %ebp
 136:	89 e5                	mov    %esp,%ebp
 138:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 13b:	8b 45 08             	mov    0x8(%ebp),%eax
 13e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 141:	90                   	nop
 142:	8b 45 08             	mov    0x8(%ebp),%eax
 145:	8d 50 01             	lea    0x1(%eax),%edx
 148:	89 55 08             	mov    %edx,0x8(%ebp)
 14b:	8b 55 0c             	mov    0xc(%ebp),%edx
 14e:	8d 4a 01             	lea    0x1(%edx),%ecx
 151:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 154:	8a 12                	mov    (%edx),%dl
 156:	88 10                	mov    %dl,(%eax)
 158:	8a 00                	mov    (%eax),%al
 15a:	84 c0                	test   %al,%al
 15c:	75 e4                	jne    142 <strcpy+0xd>
    ;
  return os;
 15e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 161:	c9                   	leave  
 162:	c3                   	ret    

00000163 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 163:	55                   	push   %ebp
 164:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 166:	eb 06                	jmp    16e <strcmp+0xb>
    p++, q++;
 168:	ff 45 08             	incl   0x8(%ebp)
 16b:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 16e:	8b 45 08             	mov    0x8(%ebp),%eax
 171:	8a 00                	mov    (%eax),%al
 173:	84 c0                	test   %al,%al
 175:	74 0e                	je     185 <strcmp+0x22>
 177:	8b 45 08             	mov    0x8(%ebp),%eax
 17a:	8a 10                	mov    (%eax),%dl
 17c:	8b 45 0c             	mov    0xc(%ebp),%eax
 17f:	8a 00                	mov    (%eax),%al
 181:	38 c2                	cmp    %al,%dl
 183:	74 e3                	je     168 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 185:	8b 45 08             	mov    0x8(%ebp),%eax
 188:	8a 00                	mov    (%eax),%al
 18a:	0f b6 d0             	movzbl %al,%edx
 18d:	8b 45 0c             	mov    0xc(%ebp),%eax
 190:	8a 00                	mov    (%eax),%al
 192:	0f b6 c0             	movzbl %al,%eax
 195:	29 c2                	sub    %eax,%edx
 197:	89 d0                	mov    %edx,%eax
}
 199:	5d                   	pop    %ebp
 19a:	c3                   	ret    

0000019b <strlen>:

uint
strlen(char *s)
{
 19b:	55                   	push   %ebp
 19c:	89 e5                	mov    %esp,%ebp
 19e:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1a1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1a8:	eb 03                	jmp    1ad <strlen+0x12>
 1aa:	ff 45 fc             	incl   -0x4(%ebp)
 1ad:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1b0:	8b 45 08             	mov    0x8(%ebp),%eax
 1b3:	01 d0                	add    %edx,%eax
 1b5:	8a 00                	mov    (%eax),%al
 1b7:	84 c0                	test   %al,%al
 1b9:	75 ef                	jne    1aa <strlen+0xf>
    ;
  return n;
 1bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1be:	c9                   	leave  
 1bf:	c3                   	ret    

000001c0 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1c0:	55                   	push   %ebp
 1c1:	89 e5                	mov    %esp,%ebp
 1c3:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 1c6:	8b 45 10             	mov    0x10(%ebp),%eax
 1c9:	89 44 24 08          	mov    %eax,0x8(%esp)
 1cd:	8b 45 0c             	mov    0xc(%ebp),%eax
 1d0:	89 44 24 04          	mov    %eax,0x4(%esp)
 1d4:	8b 45 08             	mov    0x8(%ebp),%eax
 1d7:	89 04 24             	mov    %eax,(%esp)
 1da:	e8 31 ff ff ff       	call   110 <stosb>
  return dst;
 1df:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1e2:	c9                   	leave  
 1e3:	c3                   	ret    

000001e4 <strchr>:

char*
strchr(const char *s, char c)
{
 1e4:	55                   	push   %ebp
 1e5:	89 e5                	mov    %esp,%ebp
 1e7:	83 ec 04             	sub    $0x4,%esp
 1ea:	8b 45 0c             	mov    0xc(%ebp),%eax
 1ed:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1f0:	eb 12                	jmp    204 <strchr+0x20>
    if(*s == c)
 1f2:	8b 45 08             	mov    0x8(%ebp),%eax
 1f5:	8a 00                	mov    (%eax),%al
 1f7:	3a 45 fc             	cmp    -0x4(%ebp),%al
 1fa:	75 05                	jne    201 <strchr+0x1d>
      return (char*)s;
 1fc:	8b 45 08             	mov    0x8(%ebp),%eax
 1ff:	eb 11                	jmp    212 <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 201:	ff 45 08             	incl   0x8(%ebp)
 204:	8b 45 08             	mov    0x8(%ebp),%eax
 207:	8a 00                	mov    (%eax),%al
 209:	84 c0                	test   %al,%al
 20b:	75 e5                	jne    1f2 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 20d:	b8 00 00 00 00       	mov    $0x0,%eax
}
 212:	c9                   	leave  
 213:	c3                   	ret    

00000214 <gets>:

char*
gets(char *buf, int max)
{
 214:	55                   	push   %ebp
 215:	89 e5                	mov    %esp,%ebp
 217:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 21a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 221:	eb 49                	jmp    26c <gets+0x58>
    cc = read(0, &c, 1);
 223:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 22a:	00 
 22b:	8d 45 ef             	lea    -0x11(%ebp),%eax
 22e:	89 44 24 04          	mov    %eax,0x4(%esp)
 232:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 239:	e8 3e 01 00 00       	call   37c <read>
 23e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 241:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 245:	7f 02                	jg     249 <gets+0x35>
      break;
 247:	eb 2c                	jmp    275 <gets+0x61>
    buf[i++] = c;
 249:	8b 45 f4             	mov    -0xc(%ebp),%eax
 24c:	8d 50 01             	lea    0x1(%eax),%edx
 24f:	89 55 f4             	mov    %edx,-0xc(%ebp)
 252:	89 c2                	mov    %eax,%edx
 254:	8b 45 08             	mov    0x8(%ebp),%eax
 257:	01 c2                	add    %eax,%edx
 259:	8a 45 ef             	mov    -0x11(%ebp),%al
 25c:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 25e:	8a 45 ef             	mov    -0x11(%ebp),%al
 261:	3c 0a                	cmp    $0xa,%al
 263:	74 10                	je     275 <gets+0x61>
 265:	8a 45 ef             	mov    -0x11(%ebp),%al
 268:	3c 0d                	cmp    $0xd,%al
 26a:	74 09                	je     275 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 26c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 26f:	40                   	inc    %eax
 270:	3b 45 0c             	cmp    0xc(%ebp),%eax
 273:	7c ae                	jl     223 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 275:	8b 55 f4             	mov    -0xc(%ebp),%edx
 278:	8b 45 08             	mov    0x8(%ebp),%eax
 27b:	01 d0                	add    %edx,%eax
 27d:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 280:	8b 45 08             	mov    0x8(%ebp),%eax
}
 283:	c9                   	leave  
 284:	c3                   	ret    

00000285 <stat>:

int
stat(char *n, struct stat *st)
{
 285:	55                   	push   %ebp
 286:	89 e5                	mov    %esp,%ebp
 288:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 28b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 292:	00 
 293:	8b 45 08             	mov    0x8(%ebp),%eax
 296:	89 04 24             	mov    %eax,(%esp)
 299:	e8 06 01 00 00       	call   3a4 <open>
 29e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2a1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2a5:	79 07                	jns    2ae <stat+0x29>
    return -1;
 2a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2ac:	eb 23                	jmp    2d1 <stat+0x4c>
  r = fstat(fd, st);
 2ae:	8b 45 0c             	mov    0xc(%ebp),%eax
 2b1:	89 44 24 04          	mov    %eax,0x4(%esp)
 2b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2b8:	89 04 24             	mov    %eax,(%esp)
 2bb:	e8 fc 00 00 00       	call   3bc <fstat>
 2c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2c6:	89 04 24             	mov    %eax,(%esp)
 2c9:	e8 be 00 00 00       	call   38c <close>
  return r;
 2ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2d1:	c9                   	leave  
 2d2:	c3                   	ret    

000002d3 <atoi>:

int
atoi(const char *s)
{
 2d3:	55                   	push   %ebp
 2d4:	89 e5                	mov    %esp,%ebp
 2d6:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2d9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2e0:	eb 24                	jmp    306 <atoi+0x33>
    n = n*10 + *s++ - '0';
 2e2:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2e5:	89 d0                	mov    %edx,%eax
 2e7:	c1 e0 02             	shl    $0x2,%eax
 2ea:	01 d0                	add    %edx,%eax
 2ec:	01 c0                	add    %eax,%eax
 2ee:	89 c1                	mov    %eax,%ecx
 2f0:	8b 45 08             	mov    0x8(%ebp),%eax
 2f3:	8d 50 01             	lea    0x1(%eax),%edx
 2f6:	89 55 08             	mov    %edx,0x8(%ebp)
 2f9:	8a 00                	mov    (%eax),%al
 2fb:	0f be c0             	movsbl %al,%eax
 2fe:	01 c8                	add    %ecx,%eax
 300:	83 e8 30             	sub    $0x30,%eax
 303:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 306:	8b 45 08             	mov    0x8(%ebp),%eax
 309:	8a 00                	mov    (%eax),%al
 30b:	3c 2f                	cmp    $0x2f,%al
 30d:	7e 09                	jle    318 <atoi+0x45>
 30f:	8b 45 08             	mov    0x8(%ebp),%eax
 312:	8a 00                	mov    (%eax),%al
 314:	3c 39                	cmp    $0x39,%al
 316:	7e ca                	jle    2e2 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 318:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 31b:	c9                   	leave  
 31c:	c3                   	ret    

0000031d <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 31d:	55                   	push   %ebp
 31e:	89 e5                	mov    %esp,%ebp
 320:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 323:	8b 45 08             	mov    0x8(%ebp),%eax
 326:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 329:	8b 45 0c             	mov    0xc(%ebp),%eax
 32c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 32f:	eb 16                	jmp    347 <memmove+0x2a>
    *dst++ = *src++;
 331:	8b 45 fc             	mov    -0x4(%ebp),%eax
 334:	8d 50 01             	lea    0x1(%eax),%edx
 337:	89 55 fc             	mov    %edx,-0x4(%ebp)
 33a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 33d:	8d 4a 01             	lea    0x1(%edx),%ecx
 340:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 343:	8a 12                	mov    (%edx),%dl
 345:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 347:	8b 45 10             	mov    0x10(%ebp),%eax
 34a:	8d 50 ff             	lea    -0x1(%eax),%edx
 34d:	89 55 10             	mov    %edx,0x10(%ebp)
 350:	85 c0                	test   %eax,%eax
 352:	7f dd                	jg     331 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 354:	8b 45 08             	mov    0x8(%ebp),%eax
}
 357:	c9                   	leave  
 358:	c3                   	ret    
 359:	90                   	nop
 35a:	90                   	nop
 35b:	90                   	nop

0000035c <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 35c:	b8 01 00 00 00       	mov    $0x1,%eax
 361:	cd 40                	int    $0x40
 363:	c3                   	ret    

00000364 <exit>:
SYSCALL(exit)
 364:	b8 02 00 00 00       	mov    $0x2,%eax
 369:	cd 40                	int    $0x40
 36b:	c3                   	ret    

0000036c <wait>:
SYSCALL(wait)
 36c:	b8 03 00 00 00       	mov    $0x3,%eax
 371:	cd 40                	int    $0x40
 373:	c3                   	ret    

00000374 <pipe>:
SYSCALL(pipe)
 374:	b8 04 00 00 00       	mov    $0x4,%eax
 379:	cd 40                	int    $0x40
 37b:	c3                   	ret    

0000037c <read>:
SYSCALL(read)
 37c:	b8 05 00 00 00       	mov    $0x5,%eax
 381:	cd 40                	int    $0x40
 383:	c3                   	ret    

00000384 <write>:
SYSCALL(write)
 384:	b8 10 00 00 00       	mov    $0x10,%eax
 389:	cd 40                	int    $0x40
 38b:	c3                   	ret    

0000038c <close>:
SYSCALL(close)
 38c:	b8 15 00 00 00       	mov    $0x15,%eax
 391:	cd 40                	int    $0x40
 393:	c3                   	ret    

00000394 <kill>:
SYSCALL(kill)
 394:	b8 06 00 00 00       	mov    $0x6,%eax
 399:	cd 40                	int    $0x40
 39b:	c3                   	ret    

0000039c <exec>:
SYSCALL(exec)
 39c:	b8 07 00 00 00       	mov    $0x7,%eax
 3a1:	cd 40                	int    $0x40
 3a3:	c3                   	ret    

000003a4 <open>:
SYSCALL(open)
 3a4:	b8 0f 00 00 00       	mov    $0xf,%eax
 3a9:	cd 40                	int    $0x40
 3ab:	c3                   	ret    

000003ac <mknod>:
SYSCALL(mknod)
 3ac:	b8 11 00 00 00       	mov    $0x11,%eax
 3b1:	cd 40                	int    $0x40
 3b3:	c3                   	ret    

000003b4 <unlink>:
SYSCALL(unlink)
 3b4:	b8 12 00 00 00       	mov    $0x12,%eax
 3b9:	cd 40                	int    $0x40
 3bb:	c3                   	ret    

000003bc <fstat>:
SYSCALL(fstat)
 3bc:	b8 08 00 00 00       	mov    $0x8,%eax
 3c1:	cd 40                	int    $0x40
 3c3:	c3                   	ret    

000003c4 <link>:
SYSCALL(link)
 3c4:	b8 13 00 00 00       	mov    $0x13,%eax
 3c9:	cd 40                	int    $0x40
 3cb:	c3                   	ret    

000003cc <mkdir>:
SYSCALL(mkdir)
 3cc:	b8 14 00 00 00       	mov    $0x14,%eax
 3d1:	cd 40                	int    $0x40
 3d3:	c3                   	ret    

000003d4 <chdir>:
SYSCALL(chdir)
 3d4:	b8 09 00 00 00       	mov    $0x9,%eax
 3d9:	cd 40                	int    $0x40
 3db:	c3                   	ret    

000003dc <dup>:
SYSCALL(dup)
 3dc:	b8 0a 00 00 00       	mov    $0xa,%eax
 3e1:	cd 40                	int    $0x40
 3e3:	c3                   	ret    

000003e4 <getpid>:
SYSCALL(getpid)
 3e4:	b8 0b 00 00 00       	mov    $0xb,%eax
 3e9:	cd 40                	int    $0x40
 3eb:	c3                   	ret    

000003ec <sbrk>:
SYSCALL(sbrk)
 3ec:	b8 0c 00 00 00       	mov    $0xc,%eax
 3f1:	cd 40                	int    $0x40
 3f3:	c3                   	ret    

000003f4 <sleep>:
SYSCALL(sleep)
 3f4:	b8 0d 00 00 00       	mov    $0xd,%eax
 3f9:	cd 40                	int    $0x40
 3fb:	c3                   	ret    

000003fc <uptime>:
SYSCALL(uptime)
 3fc:	b8 0e 00 00 00       	mov    $0xe,%eax
 401:	cd 40                	int    $0x40
 403:	c3                   	ret    

00000404 <mygetpid>:
SYSCALL(mygetpid)
 404:	b8 16 00 00 00       	mov    $0x16,%eax
 409:	cd 40                	int    $0x40
 40b:	c3                   	ret    

0000040c <halt>:
SYSCALL(halt)
 40c:	b8 17 00 00 00       	mov    $0x17,%eax
 411:	cd 40                	int    $0x40
 413:	c3                   	ret    

00000414 <pipe_count>:
SYSCALL(pipe_count)
 414:	b8 18 00 00 00       	mov    $0x18,%eax
 419:	cd 40                	int    $0x40
 41b:	c3                   	ret    

0000041c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 41c:	55                   	push   %ebp
 41d:	89 e5                	mov    %esp,%ebp
 41f:	83 ec 18             	sub    $0x18,%esp
 422:	8b 45 0c             	mov    0xc(%ebp),%eax
 425:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 428:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 42f:	00 
 430:	8d 45 f4             	lea    -0xc(%ebp),%eax
 433:	89 44 24 04          	mov    %eax,0x4(%esp)
 437:	8b 45 08             	mov    0x8(%ebp),%eax
 43a:	89 04 24             	mov    %eax,(%esp)
 43d:	e8 42 ff ff ff       	call   384 <write>
}
 442:	c9                   	leave  
 443:	c3                   	ret    

00000444 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 444:	55                   	push   %ebp
 445:	89 e5                	mov    %esp,%ebp
 447:	56                   	push   %esi
 448:	53                   	push   %ebx
 449:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 44c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 453:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 457:	74 17                	je     470 <printint+0x2c>
 459:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 45d:	79 11                	jns    470 <printint+0x2c>
    neg = 1;
 45f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 466:	8b 45 0c             	mov    0xc(%ebp),%eax
 469:	f7 d8                	neg    %eax
 46b:	89 45 ec             	mov    %eax,-0x14(%ebp)
 46e:	eb 06                	jmp    476 <printint+0x32>
  } else {
    x = xx;
 470:	8b 45 0c             	mov    0xc(%ebp),%eax
 473:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 476:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 47d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 480:	8d 41 01             	lea    0x1(%ecx),%eax
 483:	89 45 f4             	mov    %eax,-0xc(%ebp)
 486:	8b 5d 10             	mov    0x10(%ebp),%ebx
 489:	8b 45 ec             	mov    -0x14(%ebp),%eax
 48c:	ba 00 00 00 00       	mov    $0x0,%edx
 491:	f7 f3                	div    %ebx
 493:	89 d0                	mov    %edx,%eax
 495:	8a 80 64 0b 00 00    	mov    0xb64(%eax),%al
 49b:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 49f:	8b 75 10             	mov    0x10(%ebp),%esi
 4a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4a5:	ba 00 00 00 00       	mov    $0x0,%edx
 4aa:	f7 f6                	div    %esi
 4ac:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4af:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4b3:	75 c8                	jne    47d <printint+0x39>
  if(neg)
 4b5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4b9:	74 10                	je     4cb <printint+0x87>
    buf[i++] = '-';
 4bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4be:	8d 50 01             	lea    0x1(%eax),%edx
 4c1:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4c4:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 4c9:	eb 1e                	jmp    4e9 <printint+0xa5>
 4cb:	eb 1c                	jmp    4e9 <printint+0xa5>
    putc(fd, buf[i]);
 4cd:	8d 55 dc             	lea    -0x24(%ebp),%edx
 4d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4d3:	01 d0                	add    %edx,%eax
 4d5:	8a 00                	mov    (%eax),%al
 4d7:	0f be c0             	movsbl %al,%eax
 4da:	89 44 24 04          	mov    %eax,0x4(%esp)
 4de:	8b 45 08             	mov    0x8(%ebp),%eax
 4e1:	89 04 24             	mov    %eax,(%esp)
 4e4:	e8 33 ff ff ff       	call   41c <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 4e9:	ff 4d f4             	decl   -0xc(%ebp)
 4ec:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4f0:	79 db                	jns    4cd <printint+0x89>
    putc(fd, buf[i]);
}
 4f2:	83 c4 30             	add    $0x30,%esp
 4f5:	5b                   	pop    %ebx
 4f6:	5e                   	pop    %esi
 4f7:	5d                   	pop    %ebp
 4f8:	c3                   	ret    

000004f9 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 4f9:	55                   	push   %ebp
 4fa:	89 e5                	mov    %esp,%ebp
 4fc:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 4ff:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 506:	8d 45 0c             	lea    0xc(%ebp),%eax
 509:	83 c0 04             	add    $0x4,%eax
 50c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 50f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 516:	e9 77 01 00 00       	jmp    692 <printf+0x199>
    c = fmt[i] & 0xff;
 51b:	8b 55 0c             	mov    0xc(%ebp),%edx
 51e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 521:	01 d0                	add    %edx,%eax
 523:	8a 00                	mov    (%eax),%al
 525:	0f be c0             	movsbl %al,%eax
 528:	25 ff 00 00 00       	and    $0xff,%eax
 52d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 530:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 534:	75 2c                	jne    562 <printf+0x69>
      if(c == '%'){
 536:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 53a:	75 0c                	jne    548 <printf+0x4f>
        state = '%';
 53c:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 543:	e9 47 01 00 00       	jmp    68f <printf+0x196>
      } else {
        putc(fd, c);
 548:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 54b:	0f be c0             	movsbl %al,%eax
 54e:	89 44 24 04          	mov    %eax,0x4(%esp)
 552:	8b 45 08             	mov    0x8(%ebp),%eax
 555:	89 04 24             	mov    %eax,(%esp)
 558:	e8 bf fe ff ff       	call   41c <putc>
 55d:	e9 2d 01 00 00       	jmp    68f <printf+0x196>
      }
    } else if(state == '%'){
 562:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 566:	0f 85 23 01 00 00    	jne    68f <printf+0x196>
      if(c == 'd'){
 56c:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 570:	75 2d                	jne    59f <printf+0xa6>
        printint(fd, *ap, 10, 1);
 572:	8b 45 e8             	mov    -0x18(%ebp),%eax
 575:	8b 00                	mov    (%eax),%eax
 577:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 57e:	00 
 57f:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 586:	00 
 587:	89 44 24 04          	mov    %eax,0x4(%esp)
 58b:	8b 45 08             	mov    0x8(%ebp),%eax
 58e:	89 04 24             	mov    %eax,(%esp)
 591:	e8 ae fe ff ff       	call   444 <printint>
        ap++;
 596:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 59a:	e9 e9 00 00 00       	jmp    688 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 59f:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 5a3:	74 06                	je     5ab <printf+0xb2>
 5a5:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5a9:	75 2d                	jne    5d8 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 5ab:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5ae:	8b 00                	mov    (%eax),%eax
 5b0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 5b7:	00 
 5b8:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 5bf:	00 
 5c0:	89 44 24 04          	mov    %eax,0x4(%esp)
 5c4:	8b 45 08             	mov    0x8(%ebp),%eax
 5c7:	89 04 24             	mov    %eax,(%esp)
 5ca:	e8 75 fe ff ff       	call   444 <printint>
        ap++;
 5cf:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5d3:	e9 b0 00 00 00       	jmp    688 <printf+0x18f>
      } else if(c == 's'){
 5d8:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 5dc:	75 42                	jne    620 <printf+0x127>
        s = (char*)*ap;
 5de:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5e1:	8b 00                	mov    (%eax),%eax
 5e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 5e6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 5ea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5ee:	75 09                	jne    5f9 <printf+0x100>
          s = "(null)";
 5f0:	c7 45 f4 0f 09 00 00 	movl   $0x90f,-0xc(%ebp)
        while(*s != 0){
 5f7:	eb 1c                	jmp    615 <printf+0x11c>
 5f9:	eb 1a                	jmp    615 <printf+0x11c>
          putc(fd, *s);
 5fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5fe:	8a 00                	mov    (%eax),%al
 600:	0f be c0             	movsbl %al,%eax
 603:	89 44 24 04          	mov    %eax,0x4(%esp)
 607:	8b 45 08             	mov    0x8(%ebp),%eax
 60a:	89 04 24             	mov    %eax,(%esp)
 60d:	e8 0a fe ff ff       	call   41c <putc>
          s++;
 612:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 615:	8b 45 f4             	mov    -0xc(%ebp),%eax
 618:	8a 00                	mov    (%eax),%al
 61a:	84 c0                	test   %al,%al
 61c:	75 dd                	jne    5fb <printf+0x102>
 61e:	eb 68                	jmp    688 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 620:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 624:	75 1d                	jne    643 <printf+0x14a>
        putc(fd, *ap);
 626:	8b 45 e8             	mov    -0x18(%ebp),%eax
 629:	8b 00                	mov    (%eax),%eax
 62b:	0f be c0             	movsbl %al,%eax
 62e:	89 44 24 04          	mov    %eax,0x4(%esp)
 632:	8b 45 08             	mov    0x8(%ebp),%eax
 635:	89 04 24             	mov    %eax,(%esp)
 638:	e8 df fd ff ff       	call   41c <putc>
        ap++;
 63d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 641:	eb 45                	jmp    688 <printf+0x18f>
      } else if(c == '%'){
 643:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 647:	75 17                	jne    660 <printf+0x167>
        putc(fd, c);
 649:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 64c:	0f be c0             	movsbl %al,%eax
 64f:	89 44 24 04          	mov    %eax,0x4(%esp)
 653:	8b 45 08             	mov    0x8(%ebp),%eax
 656:	89 04 24             	mov    %eax,(%esp)
 659:	e8 be fd ff ff       	call   41c <putc>
 65e:	eb 28                	jmp    688 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 660:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 667:	00 
 668:	8b 45 08             	mov    0x8(%ebp),%eax
 66b:	89 04 24             	mov    %eax,(%esp)
 66e:	e8 a9 fd ff ff       	call   41c <putc>
        putc(fd, c);
 673:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 676:	0f be c0             	movsbl %al,%eax
 679:	89 44 24 04          	mov    %eax,0x4(%esp)
 67d:	8b 45 08             	mov    0x8(%ebp),%eax
 680:	89 04 24             	mov    %eax,(%esp)
 683:	e8 94 fd ff ff       	call   41c <putc>
      }
      state = 0;
 688:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 68f:	ff 45 f0             	incl   -0x10(%ebp)
 692:	8b 55 0c             	mov    0xc(%ebp),%edx
 695:	8b 45 f0             	mov    -0x10(%ebp),%eax
 698:	01 d0                	add    %edx,%eax
 69a:	8a 00                	mov    (%eax),%al
 69c:	84 c0                	test   %al,%al
 69e:	0f 85 77 fe ff ff    	jne    51b <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 6a4:	c9                   	leave  
 6a5:	c3                   	ret    
 6a6:	90                   	nop
 6a7:	90                   	nop

000006a8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6a8:	55                   	push   %ebp
 6a9:	89 e5                	mov    %esp,%ebp
 6ab:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6ae:	8b 45 08             	mov    0x8(%ebp),%eax
 6b1:	83 e8 08             	sub    $0x8,%eax
 6b4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6b7:	a1 80 0b 00 00       	mov    0xb80,%eax
 6bc:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6bf:	eb 24                	jmp    6e5 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c4:	8b 00                	mov    (%eax),%eax
 6c6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6c9:	77 12                	ja     6dd <free+0x35>
 6cb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ce:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6d1:	77 24                	ja     6f7 <free+0x4f>
 6d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d6:	8b 00                	mov    (%eax),%eax
 6d8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6db:	77 1a                	ja     6f7 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e0:	8b 00                	mov    (%eax),%eax
 6e2:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6e5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6e8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6eb:	76 d4                	jbe    6c1 <free+0x19>
 6ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f0:	8b 00                	mov    (%eax),%eax
 6f2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6f5:	76 ca                	jbe    6c1 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 6f7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6fa:	8b 40 04             	mov    0x4(%eax),%eax
 6fd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 704:	8b 45 f8             	mov    -0x8(%ebp),%eax
 707:	01 c2                	add    %eax,%edx
 709:	8b 45 fc             	mov    -0x4(%ebp),%eax
 70c:	8b 00                	mov    (%eax),%eax
 70e:	39 c2                	cmp    %eax,%edx
 710:	75 24                	jne    736 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 712:	8b 45 f8             	mov    -0x8(%ebp),%eax
 715:	8b 50 04             	mov    0x4(%eax),%edx
 718:	8b 45 fc             	mov    -0x4(%ebp),%eax
 71b:	8b 00                	mov    (%eax),%eax
 71d:	8b 40 04             	mov    0x4(%eax),%eax
 720:	01 c2                	add    %eax,%edx
 722:	8b 45 f8             	mov    -0x8(%ebp),%eax
 725:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 728:	8b 45 fc             	mov    -0x4(%ebp),%eax
 72b:	8b 00                	mov    (%eax),%eax
 72d:	8b 10                	mov    (%eax),%edx
 72f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 732:	89 10                	mov    %edx,(%eax)
 734:	eb 0a                	jmp    740 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 736:	8b 45 fc             	mov    -0x4(%ebp),%eax
 739:	8b 10                	mov    (%eax),%edx
 73b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 73e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 740:	8b 45 fc             	mov    -0x4(%ebp),%eax
 743:	8b 40 04             	mov    0x4(%eax),%eax
 746:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 74d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 750:	01 d0                	add    %edx,%eax
 752:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 755:	75 20                	jne    777 <free+0xcf>
    p->s.size += bp->s.size;
 757:	8b 45 fc             	mov    -0x4(%ebp),%eax
 75a:	8b 50 04             	mov    0x4(%eax),%edx
 75d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 760:	8b 40 04             	mov    0x4(%eax),%eax
 763:	01 c2                	add    %eax,%edx
 765:	8b 45 fc             	mov    -0x4(%ebp),%eax
 768:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 76b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 76e:	8b 10                	mov    (%eax),%edx
 770:	8b 45 fc             	mov    -0x4(%ebp),%eax
 773:	89 10                	mov    %edx,(%eax)
 775:	eb 08                	jmp    77f <free+0xd7>
  } else
    p->s.ptr = bp;
 777:	8b 45 fc             	mov    -0x4(%ebp),%eax
 77a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 77d:	89 10                	mov    %edx,(%eax)
  freep = p;
 77f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 782:	a3 80 0b 00 00       	mov    %eax,0xb80
}
 787:	c9                   	leave  
 788:	c3                   	ret    

00000789 <morecore>:

static Header*
morecore(uint nu)
{
 789:	55                   	push   %ebp
 78a:	89 e5                	mov    %esp,%ebp
 78c:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 78f:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 796:	77 07                	ja     79f <morecore+0x16>
    nu = 4096;
 798:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 79f:	8b 45 08             	mov    0x8(%ebp),%eax
 7a2:	c1 e0 03             	shl    $0x3,%eax
 7a5:	89 04 24             	mov    %eax,(%esp)
 7a8:	e8 3f fc ff ff       	call   3ec <sbrk>
 7ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7b0:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7b4:	75 07                	jne    7bd <morecore+0x34>
    return 0;
 7b6:	b8 00 00 00 00       	mov    $0x0,%eax
 7bb:	eb 22                	jmp    7df <morecore+0x56>
  hp = (Header*)p;
 7bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 7c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7c6:	8b 55 08             	mov    0x8(%ebp),%edx
 7c9:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 7cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7cf:	83 c0 08             	add    $0x8,%eax
 7d2:	89 04 24             	mov    %eax,(%esp)
 7d5:	e8 ce fe ff ff       	call   6a8 <free>
  return freep;
 7da:	a1 80 0b 00 00       	mov    0xb80,%eax
}
 7df:	c9                   	leave  
 7e0:	c3                   	ret    

000007e1 <malloc>:

void*
malloc(uint nbytes)
{
 7e1:	55                   	push   %ebp
 7e2:	89 e5                	mov    %esp,%ebp
 7e4:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7e7:	8b 45 08             	mov    0x8(%ebp),%eax
 7ea:	83 c0 07             	add    $0x7,%eax
 7ed:	c1 e8 03             	shr    $0x3,%eax
 7f0:	40                   	inc    %eax
 7f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 7f4:	a1 80 0b 00 00       	mov    0xb80,%eax
 7f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7fc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 800:	75 23                	jne    825 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 802:	c7 45 f0 78 0b 00 00 	movl   $0xb78,-0x10(%ebp)
 809:	8b 45 f0             	mov    -0x10(%ebp),%eax
 80c:	a3 80 0b 00 00       	mov    %eax,0xb80
 811:	a1 80 0b 00 00       	mov    0xb80,%eax
 816:	a3 78 0b 00 00       	mov    %eax,0xb78
    base.s.size = 0;
 81b:	c7 05 7c 0b 00 00 00 	movl   $0x0,0xb7c
 822:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 825:	8b 45 f0             	mov    -0x10(%ebp),%eax
 828:	8b 00                	mov    (%eax),%eax
 82a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 82d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 830:	8b 40 04             	mov    0x4(%eax),%eax
 833:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 836:	72 4d                	jb     885 <malloc+0xa4>
      if(p->s.size == nunits)
 838:	8b 45 f4             	mov    -0xc(%ebp),%eax
 83b:	8b 40 04             	mov    0x4(%eax),%eax
 83e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 841:	75 0c                	jne    84f <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 843:	8b 45 f4             	mov    -0xc(%ebp),%eax
 846:	8b 10                	mov    (%eax),%edx
 848:	8b 45 f0             	mov    -0x10(%ebp),%eax
 84b:	89 10                	mov    %edx,(%eax)
 84d:	eb 26                	jmp    875 <malloc+0x94>
      else {
        p->s.size -= nunits;
 84f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 852:	8b 40 04             	mov    0x4(%eax),%eax
 855:	2b 45 ec             	sub    -0x14(%ebp),%eax
 858:	89 c2                	mov    %eax,%edx
 85a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 85d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 860:	8b 45 f4             	mov    -0xc(%ebp),%eax
 863:	8b 40 04             	mov    0x4(%eax),%eax
 866:	c1 e0 03             	shl    $0x3,%eax
 869:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 86c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 86f:	8b 55 ec             	mov    -0x14(%ebp),%edx
 872:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 875:	8b 45 f0             	mov    -0x10(%ebp),%eax
 878:	a3 80 0b 00 00       	mov    %eax,0xb80
      return (void*)(p + 1);
 87d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 880:	83 c0 08             	add    $0x8,%eax
 883:	eb 38                	jmp    8bd <malloc+0xdc>
    }
    if(p == freep)
 885:	a1 80 0b 00 00       	mov    0xb80,%eax
 88a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 88d:	75 1b                	jne    8aa <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 88f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 892:	89 04 24             	mov    %eax,(%esp)
 895:	e8 ef fe ff ff       	call   789 <morecore>
 89a:	89 45 f4             	mov    %eax,-0xc(%ebp)
 89d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8a1:	75 07                	jne    8aa <malloc+0xc9>
        return 0;
 8a3:	b8 00 00 00 00       	mov    $0x0,%eax
 8a8:	eb 13                	jmp    8bd <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8b3:	8b 00                	mov    (%eax),%eax
 8b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 8b8:	e9 70 ff ff ff       	jmp    82d <malloc+0x4c>
}
 8bd:	c9                   	leave  
 8be:	c3                   	ret    
