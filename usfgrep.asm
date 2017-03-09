
_usfgrep:     file format elf32-i386


Disassembly of section .text:

00000000 <querySearch>:
/*--------------------------------------------------------
Function:     querySearch
Purpose:      Searches through the file line for the input 
              string given by the user
*/
int querySearch(char input[], char query[], int charCount) {
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 10             	sub    $0x10,%esp
     int i = 0; 
   6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
     int j = 0;
   d:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
     int firstLetter;
     int found = -1;
  14:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
 
     while(i < charCount)
  1b:	e9 84 00 00 00       	jmp    a4 <querySearch+0xa4>
     {
        while(input[i] != query[0] && i < charCount)
  20:	eb 03                	jmp    25 <querySearch+0x25>
        {
            i++;
  22:	ff 45 fc             	incl   -0x4(%ebp)
     int firstLetter;
     int found = -1;
 
     while(i < charCount)
     {
        while(input[i] != query[0] && i < charCount)
  25:	8b 55 fc             	mov    -0x4(%ebp),%edx
  28:	8b 45 08             	mov    0x8(%ebp),%eax
  2b:	01 d0                	add    %edx,%eax
  2d:	8a 10                	mov    (%eax),%dl
  2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  32:	8a 00                	mov    (%eax),%al
  34:	38 c2                	cmp    %al,%dl
  36:	74 08                	je     40 <querySearch+0x40>
  38:	8b 45 fc             	mov    -0x4(%ebp),%eax
  3b:	3b 45 10             	cmp    0x10(%ebp),%eax
  3e:	7c e2                	jl     22 <querySearch+0x22>
        {
            i++;
        }

        //keeps track of i in case first letter is spotted in query
        firstLetter = i;
  40:	8b 45 fc             	mov    -0x4(%ebp),%eax
  43:	89 45 f0             	mov    %eax,-0x10(%ebp)

        while (input[i] == query[j] && i < charCount && query[j] != '\0') 
  46:	eb 06                	jmp    4e <querySearch+0x4e>
        {
           i++;
  48:	ff 45 fc             	incl   -0x4(%ebp)
           j++;
  4b:	ff 45 f8             	incl   -0x8(%ebp)
        }

        //keeps track of i in case first letter is spotted in query
        firstLetter = i;

        while (input[i] == query[j] && i < charCount && query[j] != '\0') 
  4e:	8b 55 fc             	mov    -0x4(%ebp),%edx
  51:	8b 45 08             	mov    0x8(%ebp),%eax
  54:	01 d0                	add    %edx,%eax
  56:	8a 10                	mov    (%eax),%dl
  58:	8b 4d f8             	mov    -0x8(%ebp),%ecx
  5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  5e:	01 c8                	add    %ecx,%eax
  60:	8a 00                	mov    (%eax),%al
  62:	38 c2                	cmp    %al,%dl
  64:	75 16                	jne    7c <querySearch+0x7c>
  66:	8b 45 fc             	mov    -0x4(%ebp),%eax
  69:	3b 45 10             	cmp    0x10(%ebp),%eax
  6c:	7d 0e                	jge    7c <querySearch+0x7c>
  6e:	8b 55 f8             	mov    -0x8(%ebp),%edx
  71:	8b 45 0c             	mov    0xc(%ebp),%eax
  74:	01 d0                	add    %edx,%eax
  76:	8a 00                	mov    (%eax),%al
  78:	84 c0                	test   %al,%al
  7a:	75 cc                	jne    48 <querySearch+0x48>
        {
           i++;
           j++;
        }

        if (query[j] == '\0')
  7c:	8b 55 f8             	mov    -0x8(%ebp),%edx
  7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  82:	01 d0                	add    %edx,%eax
  84:	8a 00                	mov    (%eax),%al
  86:	84 c0                	test   %al,%al
  88:	75 0c                	jne    96 <querySearch+0x96>
        {
           found = 1;
  8a:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
           return found;
  91:	8b 45 f4             	mov    -0xc(%ebp),%eax
  94:	eb 1d                	jmp    b3 <querySearch+0xb3>
        }

        i = firstLetter + 1;
  96:	8b 45 f0             	mov    -0x10(%ebp),%eax
  99:	40                   	inc    %eax
  9a:	89 45 fc             	mov    %eax,-0x4(%ebp)
        j = 0;
  9d:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
     int i = 0; 
     int j = 0;
     int firstLetter;
     int found = -1;
 
     while(i < charCount)
  a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  a7:	3b 45 10             	cmp    0x10(%ebp),%eax
  aa:	0f 8c 70 ff ff ff    	jl     20 <querySearch+0x20>

        i = firstLetter + 1;
        j = 0;
     }

    return found;
  b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  b3:	c9                   	leave  
  b4:	c3                   	ret    

000000b5 <printLine>:
Function:     printLine
Purpose:      Prints the file name, line number, and line
              contents for each line that contains the 
              string given by the user
*/
void printLine(int line, int charCount, char fileLine[]) {
  b5:	55                   	push   %ebp
  b6:	89 e5                	mov    %esp,%ebp
  b8:	83 ec 28             	sub    $0x28,%esp
  printf(1,"%s[%d]: ", filename, line);
  bb:	a1 6c 0e 00 00       	mov    0xe6c,%eax
  c0:	8b 55 08             	mov    0x8(%ebp),%edx
  c3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  c7:	89 44 24 08          	mov    %eax,0x8(%esp)
  cb:	c7 44 24 04 d0 0a 00 	movl   $0xad0,0x4(%esp)
  d2:	00 
  d3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  da:	e8 2a 06 00 00       	call   709 <printf>
    int z;

    for(z = 0; z < charCount; z++)
  df:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  e6:	eb 28                	jmp    110 <printLine+0x5b>
    {
      printf(1,"%c", fileLine[z]);
  e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  eb:	8b 45 10             	mov    0x10(%ebp),%eax
  ee:	01 d0                	add    %edx,%eax
  f0:	8a 00                	mov    (%eax),%al
  f2:	0f be c0             	movsbl %al,%eax
  f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  f9:	c7 44 24 04 d9 0a 00 	movl   $0xad9,0x4(%esp)
 100:	00 
 101:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 108:	e8 fc 05 00 00       	call   709 <printf>
*/
void printLine(int line, int charCount, char fileLine[]) {
  printf(1,"%s[%d]: ", filename, line);
    int z;

    for(z = 0; z < charCount; z++)
 10d:	ff 45 f4             	incl   -0xc(%ebp)
 110:	8b 45 f4             	mov    -0xc(%ebp),%eax
 113:	3b 45 0c             	cmp    0xc(%ebp),%eax
 116:	7c d0                	jl     e8 <printLine+0x33>
    {
      printf(1,"%c", fileLine[z]);
    }

    printf(1,"\n");
 118:	c7 44 24 04 dc 0a 00 	movl   $0xadc,0x4(%esp)
 11f:	00 
 120:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 127:	e8 dd 05 00 00       	call   709 <printf>

    return;
 12c:	90                   	nop
}
 12d:	c9                   	leave  
 12e:	c3                   	ret    

0000012f <readLine>:
Purpose:      reads the file line by line to search for the 
              input string given by the user and prints out 
              the file name, line number, and line content if
              the string is found within that line
*/
int readLine(int fd) {
 12f:	55                   	push   %ebp
 130:	89 e5                	mov    %esp,%ebp
 132:	81 ec 38 02 00 00    	sub    $0x238,%esp
    int endOfFile = 0;
 138:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    char c;
    int n;
    int i = 0;
 13f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char fileLine[511];
    int charCount = 0;
 146:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    int searchResult;

    //reads in the file line by line
    while((n = read(fd, &c, 1)) > 0)
 14d:	eb 4c                	jmp    19b <readLine+0x6c>
    {
        if (c == '\n')
 14f:	8a 45 e3             	mov    -0x1d(%ebp),%al
 152:	3c 0a                	cmp    $0xa,%al
 154:	75 0d                	jne    163 <readLine+0x34>
        {
            line++;
 156:	a1 5c 0e 00 00       	mov    0xe5c,%eax
 15b:	40                   	inc    %eax
 15c:	a3 5c 0e 00 00       	mov    %eax,0xe5c
            break;
 161:	eb 5b                	jmp    1be <readLine+0x8f>
        } 
        else
        {
            fileLine[i] = c;
 163:	8a 45 e3             	mov    -0x1d(%ebp),%al
 166:	8d 8d e4 fd ff ff    	lea    -0x21c(%ebp),%ecx
 16c:	8b 55 f0             	mov    -0x10(%ebp),%edx
 16f:	01 ca                	add    %ecx,%edx
 171:	88 02                	mov    %al,(%edx)
            charCount++;
 173:	ff 45 ec             	incl   -0x14(%ebp)
            if(charCount > 511){
 176:	81 7d ec ff 01 00 00 	cmpl   $0x1ff,-0x14(%ebp)
 17d:	7e 19                	jle    198 <readLine+0x69>
              printf(1,"This file has exceeded the max number of chars in one line. Good bye.\n");
 17f:	c7 44 24 04 e0 0a 00 	movl   $0xae0,0x4(%esp)
 186:	00 
 187:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 18e:	e8 76 05 00 00       	call   709 <printf>
                exit();
 193:	e8 dc 03 00 00       	call   574 <exit>
            }
        }
        i++;
 198:	ff 45 f0             	incl   -0x10(%ebp)
    char fileLine[511];
    int charCount = 0;
    int searchResult;

    //reads in the file line by line
    while((n = read(fd, &c, 1)) > 0)
 19b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 1a2:	00 
 1a3:	8d 45 e3             	lea    -0x1d(%ebp),%eax
 1a6:	89 44 24 04          	mov    %eax,0x4(%esp)
 1aa:	8b 45 08             	mov    0x8(%ebp),%eax
 1ad:	89 04 24             	mov    %eax,(%esp)
 1b0:	e8 d7 03 00 00       	call   58c <read>
 1b5:	89 45 e8             	mov    %eax,-0x18(%ebp)
 1b8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
 1bc:	7f 91                	jg     14f <readLine+0x20>
        }
        i++;
    }

    //checks if last line with remaining characters
    if(charCount > 0 && n == 0)
 1be:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 1c2:	7e 18                	jle    1dc <readLine+0xad>
 1c4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
 1c8:	75 12                	jne    1dc <readLine+0xad>
    {
        endOfFile = -1;
 1ca:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
        line++;
 1d1:	a1 5c 0e 00 00       	mov    0xe5c,%eax
 1d6:	40                   	inc    %eax
 1d7:	a3 5c 0e 00 00       	mov    %eax,0xe5c
    }

    //if end of file with blank line or empty text file
    if(charCount == 0 && n == 0)
 1dc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 1e0:	75 0d                	jne    1ef <readLine+0xc0>
 1e2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
 1e6:	75 07                	jne    1ef <readLine+0xc0>
    {
        endOfFile = -1;
 1e8:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
    }

    //prints the line info if there is a match
    if((searchResult = querySearch(fileLine, query, charCount)) == 1)
 1ef:	a1 70 0e 00 00       	mov    0xe70,%eax
 1f4:	8b 55 ec             	mov    -0x14(%ebp),%edx
 1f7:	89 54 24 08          	mov    %edx,0x8(%esp)
 1fb:	89 44 24 04          	mov    %eax,0x4(%esp)
 1ff:	8d 85 e4 fd ff ff    	lea    -0x21c(%ebp),%eax
 205:	89 04 24             	mov    %eax,(%esp)
 208:	e8 f3 fd ff ff       	call   0 <querySearch>
 20d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 210:	83 7d e4 01          	cmpl   $0x1,-0x1c(%ebp)
 214:	75 1e                	jne    234 <readLine+0x105>
    {
        printLine(line, charCount, fileLine);
 216:	a1 5c 0e 00 00       	mov    0xe5c,%eax
 21b:	8d 95 e4 fd ff ff    	lea    -0x21c(%ebp),%edx
 221:	89 54 24 08          	mov    %edx,0x8(%esp)
 225:	8b 55 ec             	mov    -0x14(%ebp),%edx
 228:	89 54 24 04          	mov    %edx,0x4(%esp)
 22c:	89 04 24             	mov    %eax,(%esp)
 22f:	e8 81 fe ff ff       	call   b5 <printLine>
    }

    return endOfFile;
 234:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
 237:	c9                   	leave  
 238:	c3                   	ret    

00000239 <readFile>:
/*--------------------------------------------------------
Function:     readFile
Purpose:      Reads through the file until the end of the 
              file is reached
*/
void readFile(int fd) {
 239:	55                   	push   %ebp
 23a:	89 e5                	mov    %esp,%ebp
 23c:	83 ec 28             	sub    $0x28,%esp
    int endOfFile;

    while((endOfFile = readLine(fd)) >= 0);
 23f:	8b 45 08             	mov    0x8(%ebp),%eax
 242:	89 04 24             	mov    %eax,(%esp)
 245:	e8 e5 fe ff ff       	call   12f <readLine>
 24a:	89 45 f4             	mov    %eax,-0xc(%ebp)
 24d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 251:	79 ec                	jns    23f <readFile+0x6>

    return;
 253:	90                   	nop
}
 254:	c9                   	leave  
 255:	c3                   	ret    

00000256 <main>:

/*--------------------------------------------------------*/
int main(int argc, char *argv[]) {
 256:	55                   	push   %ebp
 257:	89 e5                	mov    %esp,%ebp
 259:	83 e4 f0             	and    $0xfffffff0,%esp
 25c:	83 ec 20             	sub    $0x20,%esp
    int fd;

    if (argc <= 2)
 25f:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
 263:	7f 19                	jg     27e <main+0x28>
    {
      printf(1,"Insufficient arguments\nUsage: usfgrep <string> <file1> [<file2>...]\n");
 265:	c7 44 24 04 28 0b 00 	movl   $0xb28,0x4(%esp)
 26c:	00 
 26d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 274:	e8 90 04 00 00       	call   709 <printf>
        exit();
 279:	e8 f6 02 00 00       	call   574 <exit>
    }

    query = argv[1];
 27e:	8b 45 0c             	mov    0xc(%ebp),%eax
 281:	8b 40 04             	mov    0x4(%eax),%eax
 284:	a3 70 0e 00 00       	mov    %eax,0xe70

    int v;
    for(v = 2; v < argc; v++)
 289:	c7 44 24 18 02 00 00 	movl   $0x2,0x18(%esp)
 290:	00 
 291:	eb 70                	jmp    303 <main+0xad>
    {
        filename = argv[v];
 293:	8b 44 24 18          	mov    0x18(%esp),%eax
 297:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 29e:	8b 45 0c             	mov    0xc(%ebp),%eax
 2a1:	01 d0                	add    %edx,%eax
 2a3:	8b 00                	mov    (%eax),%eax
 2a5:	a3 6c 0e 00 00       	mov    %eax,0xe6c
        line = 0;
 2aa:	c7 05 5c 0e 00 00 00 	movl   $0x0,0xe5c
 2b1:	00 00 00 

        fd = open(filename, O_RDONLY);
 2b4:	a1 6c 0e 00 00       	mov    0xe6c,%eax
 2b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 2c0:	00 
 2c1:	89 04 24             	mov    %eax,(%esp)
 2c4:	e8 eb 02 00 00       	call   5b4 <open>
 2c9:	89 44 24 1c          	mov    %eax,0x1c(%esp)

         //If fd has negative number there is an error
        if (fd < 0)
 2cd:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
 2d2:	79 1f                	jns    2f3 <main+0x9d>
        {
          printf(1,"Cannot open %s\n", filename);
 2d4:	a1 6c 0e 00 00       	mov    0xe6c,%eax
 2d9:	89 44 24 08          	mov    %eax,0x8(%esp)
 2dd:	c7 44 24 04 6d 0b 00 	movl   $0xb6d,0x4(%esp)
 2e4:	00 
 2e5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2ec:	e8 18 04 00 00       	call   709 <printf>
 2f1:	eb 0c                	jmp    2ff <main+0xa9>
        }
        else{
            readFile(fd);
 2f3:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 2f7:	89 04 24             	mov    %eax,(%esp)
 2fa:	e8 3a ff ff ff       	call   239 <readFile>
    }

    query = argv[1];

    int v;
    for(v = 2; v < argc; v++)
 2ff:	ff 44 24 18          	incl   0x18(%esp)
 303:	8b 44 24 18          	mov    0x18(%esp),%eax
 307:	3b 45 08             	cmp    0x8(%ebp),%eax
 30a:	7c 87                	jl     293 <main+0x3d>
            readFile(fd);
        }

    }
    
    close(fd);
 30c:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 310:	89 04 24             	mov    %eax,(%esp)
 313:	e8 84 02 00 00       	call   59c <close>

    exit();
 318:	e8 57 02 00 00       	call   574 <exit>
 31d:	90                   	nop
 31e:	90                   	nop
 31f:	90                   	nop

00000320 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 320:	55                   	push   %ebp
 321:	89 e5                	mov    %esp,%ebp
 323:	57                   	push   %edi
 324:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 325:	8b 4d 08             	mov    0x8(%ebp),%ecx
 328:	8b 55 10             	mov    0x10(%ebp),%edx
 32b:	8b 45 0c             	mov    0xc(%ebp),%eax
 32e:	89 cb                	mov    %ecx,%ebx
 330:	89 df                	mov    %ebx,%edi
 332:	89 d1                	mov    %edx,%ecx
 334:	fc                   	cld    
 335:	f3 aa                	rep stos %al,%es:(%edi)
 337:	89 ca                	mov    %ecx,%edx
 339:	89 fb                	mov    %edi,%ebx
 33b:	89 5d 08             	mov    %ebx,0x8(%ebp)
 33e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 341:	5b                   	pop    %ebx
 342:	5f                   	pop    %edi
 343:	5d                   	pop    %ebp
 344:	c3                   	ret    

00000345 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 345:	55                   	push   %ebp
 346:	89 e5                	mov    %esp,%ebp
 348:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 34b:	8b 45 08             	mov    0x8(%ebp),%eax
 34e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 351:	90                   	nop
 352:	8b 45 08             	mov    0x8(%ebp),%eax
 355:	8d 50 01             	lea    0x1(%eax),%edx
 358:	89 55 08             	mov    %edx,0x8(%ebp)
 35b:	8b 55 0c             	mov    0xc(%ebp),%edx
 35e:	8d 4a 01             	lea    0x1(%edx),%ecx
 361:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 364:	8a 12                	mov    (%edx),%dl
 366:	88 10                	mov    %dl,(%eax)
 368:	8a 00                	mov    (%eax),%al
 36a:	84 c0                	test   %al,%al
 36c:	75 e4                	jne    352 <strcpy+0xd>
    ;
  return os;
 36e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 371:	c9                   	leave  
 372:	c3                   	ret    

00000373 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 373:	55                   	push   %ebp
 374:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 376:	eb 06                	jmp    37e <strcmp+0xb>
    p++, q++;
 378:	ff 45 08             	incl   0x8(%ebp)
 37b:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 37e:	8b 45 08             	mov    0x8(%ebp),%eax
 381:	8a 00                	mov    (%eax),%al
 383:	84 c0                	test   %al,%al
 385:	74 0e                	je     395 <strcmp+0x22>
 387:	8b 45 08             	mov    0x8(%ebp),%eax
 38a:	8a 10                	mov    (%eax),%dl
 38c:	8b 45 0c             	mov    0xc(%ebp),%eax
 38f:	8a 00                	mov    (%eax),%al
 391:	38 c2                	cmp    %al,%dl
 393:	74 e3                	je     378 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 395:	8b 45 08             	mov    0x8(%ebp),%eax
 398:	8a 00                	mov    (%eax),%al
 39a:	0f b6 d0             	movzbl %al,%edx
 39d:	8b 45 0c             	mov    0xc(%ebp),%eax
 3a0:	8a 00                	mov    (%eax),%al
 3a2:	0f b6 c0             	movzbl %al,%eax
 3a5:	29 c2                	sub    %eax,%edx
 3a7:	89 d0                	mov    %edx,%eax
}
 3a9:	5d                   	pop    %ebp
 3aa:	c3                   	ret    

000003ab <strlen>:

uint
strlen(char *s)
{
 3ab:	55                   	push   %ebp
 3ac:	89 e5                	mov    %esp,%ebp
 3ae:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 3b1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 3b8:	eb 03                	jmp    3bd <strlen+0x12>
 3ba:	ff 45 fc             	incl   -0x4(%ebp)
 3bd:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3c0:	8b 45 08             	mov    0x8(%ebp),%eax
 3c3:	01 d0                	add    %edx,%eax
 3c5:	8a 00                	mov    (%eax),%al
 3c7:	84 c0                	test   %al,%al
 3c9:	75 ef                	jne    3ba <strlen+0xf>
    ;
  return n;
 3cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3ce:	c9                   	leave  
 3cf:	c3                   	ret    

000003d0 <memset>:

void*
memset(void *dst, int c, uint n)
{
 3d0:	55                   	push   %ebp
 3d1:	89 e5                	mov    %esp,%ebp
 3d3:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 3d6:	8b 45 10             	mov    0x10(%ebp),%eax
 3d9:	89 44 24 08          	mov    %eax,0x8(%esp)
 3dd:	8b 45 0c             	mov    0xc(%ebp),%eax
 3e0:	89 44 24 04          	mov    %eax,0x4(%esp)
 3e4:	8b 45 08             	mov    0x8(%ebp),%eax
 3e7:	89 04 24             	mov    %eax,(%esp)
 3ea:	e8 31 ff ff ff       	call   320 <stosb>
  return dst;
 3ef:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3f2:	c9                   	leave  
 3f3:	c3                   	ret    

000003f4 <strchr>:

char*
strchr(const char *s, char c)
{
 3f4:	55                   	push   %ebp
 3f5:	89 e5                	mov    %esp,%ebp
 3f7:	83 ec 04             	sub    $0x4,%esp
 3fa:	8b 45 0c             	mov    0xc(%ebp),%eax
 3fd:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 400:	eb 12                	jmp    414 <strchr+0x20>
    if(*s == c)
 402:	8b 45 08             	mov    0x8(%ebp),%eax
 405:	8a 00                	mov    (%eax),%al
 407:	3a 45 fc             	cmp    -0x4(%ebp),%al
 40a:	75 05                	jne    411 <strchr+0x1d>
      return (char*)s;
 40c:	8b 45 08             	mov    0x8(%ebp),%eax
 40f:	eb 11                	jmp    422 <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 411:	ff 45 08             	incl   0x8(%ebp)
 414:	8b 45 08             	mov    0x8(%ebp),%eax
 417:	8a 00                	mov    (%eax),%al
 419:	84 c0                	test   %al,%al
 41b:	75 e5                	jne    402 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 41d:	b8 00 00 00 00       	mov    $0x0,%eax
}
 422:	c9                   	leave  
 423:	c3                   	ret    

00000424 <gets>:

char*
gets(char *buf, int max)
{
 424:	55                   	push   %ebp
 425:	89 e5                	mov    %esp,%ebp
 427:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 42a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 431:	eb 49                	jmp    47c <gets+0x58>
    cc = read(0, &c, 1);
 433:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 43a:	00 
 43b:	8d 45 ef             	lea    -0x11(%ebp),%eax
 43e:	89 44 24 04          	mov    %eax,0x4(%esp)
 442:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 449:	e8 3e 01 00 00       	call   58c <read>
 44e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 451:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 455:	7f 02                	jg     459 <gets+0x35>
      break;
 457:	eb 2c                	jmp    485 <gets+0x61>
    buf[i++] = c;
 459:	8b 45 f4             	mov    -0xc(%ebp),%eax
 45c:	8d 50 01             	lea    0x1(%eax),%edx
 45f:	89 55 f4             	mov    %edx,-0xc(%ebp)
 462:	89 c2                	mov    %eax,%edx
 464:	8b 45 08             	mov    0x8(%ebp),%eax
 467:	01 c2                	add    %eax,%edx
 469:	8a 45 ef             	mov    -0x11(%ebp),%al
 46c:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 46e:	8a 45 ef             	mov    -0x11(%ebp),%al
 471:	3c 0a                	cmp    $0xa,%al
 473:	74 10                	je     485 <gets+0x61>
 475:	8a 45 ef             	mov    -0x11(%ebp),%al
 478:	3c 0d                	cmp    $0xd,%al
 47a:	74 09                	je     485 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 47c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 47f:	40                   	inc    %eax
 480:	3b 45 0c             	cmp    0xc(%ebp),%eax
 483:	7c ae                	jl     433 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 485:	8b 55 f4             	mov    -0xc(%ebp),%edx
 488:	8b 45 08             	mov    0x8(%ebp),%eax
 48b:	01 d0                	add    %edx,%eax
 48d:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 490:	8b 45 08             	mov    0x8(%ebp),%eax
}
 493:	c9                   	leave  
 494:	c3                   	ret    

00000495 <stat>:

int
stat(char *n, struct stat *st)
{
 495:	55                   	push   %ebp
 496:	89 e5                	mov    %esp,%ebp
 498:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 49b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 4a2:	00 
 4a3:	8b 45 08             	mov    0x8(%ebp),%eax
 4a6:	89 04 24             	mov    %eax,(%esp)
 4a9:	e8 06 01 00 00       	call   5b4 <open>
 4ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 4b1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4b5:	79 07                	jns    4be <stat+0x29>
    return -1;
 4b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 4bc:	eb 23                	jmp    4e1 <stat+0x4c>
  r = fstat(fd, st);
 4be:	8b 45 0c             	mov    0xc(%ebp),%eax
 4c1:	89 44 24 04          	mov    %eax,0x4(%esp)
 4c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4c8:	89 04 24             	mov    %eax,(%esp)
 4cb:	e8 fc 00 00 00       	call   5cc <fstat>
 4d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 4d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4d6:	89 04 24             	mov    %eax,(%esp)
 4d9:	e8 be 00 00 00       	call   59c <close>
  return r;
 4de:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 4e1:	c9                   	leave  
 4e2:	c3                   	ret    

000004e3 <atoi>:

int
atoi(const char *s)
{
 4e3:	55                   	push   %ebp
 4e4:	89 e5                	mov    %esp,%ebp
 4e6:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 4e9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 4f0:	eb 24                	jmp    516 <atoi+0x33>
    n = n*10 + *s++ - '0';
 4f2:	8b 55 fc             	mov    -0x4(%ebp),%edx
 4f5:	89 d0                	mov    %edx,%eax
 4f7:	c1 e0 02             	shl    $0x2,%eax
 4fa:	01 d0                	add    %edx,%eax
 4fc:	01 c0                	add    %eax,%eax
 4fe:	89 c1                	mov    %eax,%ecx
 500:	8b 45 08             	mov    0x8(%ebp),%eax
 503:	8d 50 01             	lea    0x1(%eax),%edx
 506:	89 55 08             	mov    %edx,0x8(%ebp)
 509:	8a 00                	mov    (%eax),%al
 50b:	0f be c0             	movsbl %al,%eax
 50e:	01 c8                	add    %ecx,%eax
 510:	83 e8 30             	sub    $0x30,%eax
 513:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 516:	8b 45 08             	mov    0x8(%ebp),%eax
 519:	8a 00                	mov    (%eax),%al
 51b:	3c 2f                	cmp    $0x2f,%al
 51d:	7e 09                	jle    528 <atoi+0x45>
 51f:	8b 45 08             	mov    0x8(%ebp),%eax
 522:	8a 00                	mov    (%eax),%al
 524:	3c 39                	cmp    $0x39,%al
 526:	7e ca                	jle    4f2 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 528:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 52b:	c9                   	leave  
 52c:	c3                   	ret    

0000052d <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 52d:	55                   	push   %ebp
 52e:	89 e5                	mov    %esp,%ebp
 530:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 533:	8b 45 08             	mov    0x8(%ebp),%eax
 536:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 539:	8b 45 0c             	mov    0xc(%ebp),%eax
 53c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 53f:	eb 16                	jmp    557 <memmove+0x2a>
    *dst++ = *src++;
 541:	8b 45 fc             	mov    -0x4(%ebp),%eax
 544:	8d 50 01             	lea    0x1(%eax),%edx
 547:	89 55 fc             	mov    %edx,-0x4(%ebp)
 54a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 54d:	8d 4a 01             	lea    0x1(%edx),%ecx
 550:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 553:	8a 12                	mov    (%edx),%dl
 555:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 557:	8b 45 10             	mov    0x10(%ebp),%eax
 55a:	8d 50 ff             	lea    -0x1(%eax),%edx
 55d:	89 55 10             	mov    %edx,0x10(%ebp)
 560:	85 c0                	test   %eax,%eax
 562:	7f dd                	jg     541 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 564:	8b 45 08             	mov    0x8(%ebp),%eax
}
 567:	c9                   	leave  
 568:	c3                   	ret    
 569:	90                   	nop
 56a:	90                   	nop
 56b:	90                   	nop

0000056c <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 56c:	b8 01 00 00 00       	mov    $0x1,%eax
 571:	cd 40                	int    $0x40
 573:	c3                   	ret    

00000574 <exit>:
SYSCALL(exit)
 574:	b8 02 00 00 00       	mov    $0x2,%eax
 579:	cd 40                	int    $0x40
 57b:	c3                   	ret    

0000057c <wait>:
SYSCALL(wait)
 57c:	b8 03 00 00 00       	mov    $0x3,%eax
 581:	cd 40                	int    $0x40
 583:	c3                   	ret    

00000584 <pipe>:
SYSCALL(pipe)
 584:	b8 04 00 00 00       	mov    $0x4,%eax
 589:	cd 40                	int    $0x40
 58b:	c3                   	ret    

0000058c <read>:
SYSCALL(read)
 58c:	b8 05 00 00 00       	mov    $0x5,%eax
 591:	cd 40                	int    $0x40
 593:	c3                   	ret    

00000594 <write>:
SYSCALL(write)
 594:	b8 10 00 00 00       	mov    $0x10,%eax
 599:	cd 40                	int    $0x40
 59b:	c3                   	ret    

0000059c <close>:
SYSCALL(close)
 59c:	b8 15 00 00 00       	mov    $0x15,%eax
 5a1:	cd 40                	int    $0x40
 5a3:	c3                   	ret    

000005a4 <kill>:
SYSCALL(kill)
 5a4:	b8 06 00 00 00       	mov    $0x6,%eax
 5a9:	cd 40                	int    $0x40
 5ab:	c3                   	ret    

000005ac <exec>:
SYSCALL(exec)
 5ac:	b8 07 00 00 00       	mov    $0x7,%eax
 5b1:	cd 40                	int    $0x40
 5b3:	c3                   	ret    

000005b4 <open>:
SYSCALL(open)
 5b4:	b8 0f 00 00 00       	mov    $0xf,%eax
 5b9:	cd 40                	int    $0x40
 5bb:	c3                   	ret    

000005bc <mknod>:
SYSCALL(mknod)
 5bc:	b8 11 00 00 00       	mov    $0x11,%eax
 5c1:	cd 40                	int    $0x40
 5c3:	c3                   	ret    

000005c4 <unlink>:
SYSCALL(unlink)
 5c4:	b8 12 00 00 00       	mov    $0x12,%eax
 5c9:	cd 40                	int    $0x40
 5cb:	c3                   	ret    

000005cc <fstat>:
SYSCALL(fstat)
 5cc:	b8 08 00 00 00       	mov    $0x8,%eax
 5d1:	cd 40                	int    $0x40
 5d3:	c3                   	ret    

000005d4 <link>:
SYSCALL(link)
 5d4:	b8 13 00 00 00       	mov    $0x13,%eax
 5d9:	cd 40                	int    $0x40
 5db:	c3                   	ret    

000005dc <mkdir>:
SYSCALL(mkdir)
 5dc:	b8 14 00 00 00       	mov    $0x14,%eax
 5e1:	cd 40                	int    $0x40
 5e3:	c3                   	ret    

000005e4 <chdir>:
SYSCALL(chdir)
 5e4:	b8 09 00 00 00       	mov    $0x9,%eax
 5e9:	cd 40                	int    $0x40
 5eb:	c3                   	ret    

000005ec <dup>:
SYSCALL(dup)
 5ec:	b8 0a 00 00 00       	mov    $0xa,%eax
 5f1:	cd 40                	int    $0x40
 5f3:	c3                   	ret    

000005f4 <getpid>:
SYSCALL(getpid)
 5f4:	b8 0b 00 00 00       	mov    $0xb,%eax
 5f9:	cd 40                	int    $0x40
 5fb:	c3                   	ret    

000005fc <sbrk>:
SYSCALL(sbrk)
 5fc:	b8 0c 00 00 00       	mov    $0xc,%eax
 601:	cd 40                	int    $0x40
 603:	c3                   	ret    

00000604 <sleep>:
SYSCALL(sleep)
 604:	b8 0d 00 00 00       	mov    $0xd,%eax
 609:	cd 40                	int    $0x40
 60b:	c3                   	ret    

0000060c <uptime>:
SYSCALL(uptime)
 60c:	b8 0e 00 00 00       	mov    $0xe,%eax
 611:	cd 40                	int    $0x40
 613:	c3                   	ret    

00000614 <mygetpid>:
SYSCALL(mygetpid)
 614:	b8 16 00 00 00       	mov    $0x16,%eax
 619:	cd 40                	int    $0x40
 61b:	c3                   	ret    

0000061c <halt>:
SYSCALL(halt)
 61c:	b8 17 00 00 00       	mov    $0x17,%eax
 621:	cd 40                	int    $0x40
 623:	c3                   	ret    

00000624 <pipe_count>:
SYSCALL(pipe_count)
 624:	b8 18 00 00 00       	mov    $0x18,%eax
 629:	cd 40                	int    $0x40
 62b:	c3                   	ret    

0000062c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 62c:	55                   	push   %ebp
 62d:	89 e5                	mov    %esp,%ebp
 62f:	83 ec 18             	sub    $0x18,%esp
 632:	8b 45 0c             	mov    0xc(%ebp),%eax
 635:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 638:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 63f:	00 
 640:	8d 45 f4             	lea    -0xc(%ebp),%eax
 643:	89 44 24 04          	mov    %eax,0x4(%esp)
 647:	8b 45 08             	mov    0x8(%ebp),%eax
 64a:	89 04 24             	mov    %eax,(%esp)
 64d:	e8 42 ff ff ff       	call   594 <write>
}
 652:	c9                   	leave  
 653:	c3                   	ret    

00000654 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 654:	55                   	push   %ebp
 655:	89 e5                	mov    %esp,%ebp
 657:	56                   	push   %esi
 658:	53                   	push   %ebx
 659:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 65c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 663:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 667:	74 17                	je     680 <printint+0x2c>
 669:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 66d:	79 11                	jns    680 <printint+0x2c>
    neg = 1;
 66f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 676:	8b 45 0c             	mov    0xc(%ebp),%eax
 679:	f7 d8                	neg    %eax
 67b:	89 45 ec             	mov    %eax,-0x14(%ebp)
 67e:	eb 06                	jmp    686 <printint+0x32>
  } else {
    x = xx;
 680:	8b 45 0c             	mov    0xc(%ebp),%eax
 683:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 686:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 68d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 690:	8d 41 01             	lea    0x1(%ecx),%eax
 693:	89 45 f4             	mov    %eax,-0xc(%ebp)
 696:	8b 5d 10             	mov    0x10(%ebp),%ebx
 699:	8b 45 ec             	mov    -0x14(%ebp),%eax
 69c:	ba 00 00 00 00       	mov    $0x0,%edx
 6a1:	f7 f3                	div    %ebx
 6a3:	89 d0                	mov    %edx,%eax
 6a5:	8a 80 48 0e 00 00    	mov    0xe48(%eax),%al
 6ab:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 6af:	8b 75 10             	mov    0x10(%ebp),%esi
 6b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6b5:	ba 00 00 00 00       	mov    $0x0,%edx
 6ba:	f7 f6                	div    %esi
 6bc:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6bf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6c3:	75 c8                	jne    68d <printint+0x39>
  if(neg)
 6c5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 6c9:	74 10                	je     6db <printint+0x87>
    buf[i++] = '-';
 6cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6ce:	8d 50 01             	lea    0x1(%eax),%edx
 6d1:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6d4:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 6d9:	eb 1e                	jmp    6f9 <printint+0xa5>
 6db:	eb 1c                	jmp    6f9 <printint+0xa5>
    putc(fd, buf[i]);
 6dd:	8d 55 dc             	lea    -0x24(%ebp),%edx
 6e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6e3:	01 d0                	add    %edx,%eax
 6e5:	8a 00                	mov    (%eax),%al
 6e7:	0f be c0             	movsbl %al,%eax
 6ea:	89 44 24 04          	mov    %eax,0x4(%esp)
 6ee:	8b 45 08             	mov    0x8(%ebp),%eax
 6f1:	89 04 24             	mov    %eax,(%esp)
 6f4:	e8 33 ff ff ff       	call   62c <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 6f9:	ff 4d f4             	decl   -0xc(%ebp)
 6fc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 700:	79 db                	jns    6dd <printint+0x89>
    putc(fd, buf[i]);
}
 702:	83 c4 30             	add    $0x30,%esp
 705:	5b                   	pop    %ebx
 706:	5e                   	pop    %esi
 707:	5d                   	pop    %ebp
 708:	c3                   	ret    

00000709 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 709:	55                   	push   %ebp
 70a:	89 e5                	mov    %esp,%ebp
 70c:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 70f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 716:	8d 45 0c             	lea    0xc(%ebp),%eax
 719:	83 c0 04             	add    $0x4,%eax
 71c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 71f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 726:	e9 77 01 00 00       	jmp    8a2 <printf+0x199>
    c = fmt[i] & 0xff;
 72b:	8b 55 0c             	mov    0xc(%ebp),%edx
 72e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 731:	01 d0                	add    %edx,%eax
 733:	8a 00                	mov    (%eax),%al
 735:	0f be c0             	movsbl %al,%eax
 738:	25 ff 00 00 00       	and    $0xff,%eax
 73d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 740:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 744:	75 2c                	jne    772 <printf+0x69>
      if(c == '%'){
 746:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 74a:	75 0c                	jne    758 <printf+0x4f>
        state = '%';
 74c:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 753:	e9 47 01 00 00       	jmp    89f <printf+0x196>
      } else {
        putc(fd, c);
 758:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 75b:	0f be c0             	movsbl %al,%eax
 75e:	89 44 24 04          	mov    %eax,0x4(%esp)
 762:	8b 45 08             	mov    0x8(%ebp),%eax
 765:	89 04 24             	mov    %eax,(%esp)
 768:	e8 bf fe ff ff       	call   62c <putc>
 76d:	e9 2d 01 00 00       	jmp    89f <printf+0x196>
      }
    } else if(state == '%'){
 772:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 776:	0f 85 23 01 00 00    	jne    89f <printf+0x196>
      if(c == 'd'){
 77c:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 780:	75 2d                	jne    7af <printf+0xa6>
        printint(fd, *ap, 10, 1);
 782:	8b 45 e8             	mov    -0x18(%ebp),%eax
 785:	8b 00                	mov    (%eax),%eax
 787:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 78e:	00 
 78f:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 796:	00 
 797:	89 44 24 04          	mov    %eax,0x4(%esp)
 79b:	8b 45 08             	mov    0x8(%ebp),%eax
 79e:	89 04 24             	mov    %eax,(%esp)
 7a1:	e8 ae fe ff ff       	call   654 <printint>
        ap++;
 7a6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7aa:	e9 e9 00 00 00       	jmp    898 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 7af:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 7b3:	74 06                	je     7bb <printf+0xb2>
 7b5:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 7b9:	75 2d                	jne    7e8 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 7bb:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7be:	8b 00                	mov    (%eax),%eax
 7c0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 7c7:	00 
 7c8:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 7cf:	00 
 7d0:	89 44 24 04          	mov    %eax,0x4(%esp)
 7d4:	8b 45 08             	mov    0x8(%ebp),%eax
 7d7:	89 04 24             	mov    %eax,(%esp)
 7da:	e8 75 fe ff ff       	call   654 <printint>
        ap++;
 7df:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7e3:	e9 b0 00 00 00       	jmp    898 <printf+0x18f>
      } else if(c == 's'){
 7e8:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 7ec:	75 42                	jne    830 <printf+0x127>
        s = (char*)*ap;
 7ee:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7f1:	8b 00                	mov    (%eax),%eax
 7f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 7f6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 7fa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7fe:	75 09                	jne    809 <printf+0x100>
          s = "(null)";
 800:	c7 45 f4 7d 0b 00 00 	movl   $0xb7d,-0xc(%ebp)
        while(*s != 0){
 807:	eb 1c                	jmp    825 <printf+0x11c>
 809:	eb 1a                	jmp    825 <printf+0x11c>
          putc(fd, *s);
 80b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 80e:	8a 00                	mov    (%eax),%al
 810:	0f be c0             	movsbl %al,%eax
 813:	89 44 24 04          	mov    %eax,0x4(%esp)
 817:	8b 45 08             	mov    0x8(%ebp),%eax
 81a:	89 04 24             	mov    %eax,(%esp)
 81d:	e8 0a fe ff ff       	call   62c <putc>
          s++;
 822:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 825:	8b 45 f4             	mov    -0xc(%ebp),%eax
 828:	8a 00                	mov    (%eax),%al
 82a:	84 c0                	test   %al,%al
 82c:	75 dd                	jne    80b <printf+0x102>
 82e:	eb 68                	jmp    898 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 830:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 834:	75 1d                	jne    853 <printf+0x14a>
        putc(fd, *ap);
 836:	8b 45 e8             	mov    -0x18(%ebp),%eax
 839:	8b 00                	mov    (%eax),%eax
 83b:	0f be c0             	movsbl %al,%eax
 83e:	89 44 24 04          	mov    %eax,0x4(%esp)
 842:	8b 45 08             	mov    0x8(%ebp),%eax
 845:	89 04 24             	mov    %eax,(%esp)
 848:	e8 df fd ff ff       	call   62c <putc>
        ap++;
 84d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 851:	eb 45                	jmp    898 <printf+0x18f>
      } else if(c == '%'){
 853:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 857:	75 17                	jne    870 <printf+0x167>
        putc(fd, c);
 859:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 85c:	0f be c0             	movsbl %al,%eax
 85f:	89 44 24 04          	mov    %eax,0x4(%esp)
 863:	8b 45 08             	mov    0x8(%ebp),%eax
 866:	89 04 24             	mov    %eax,(%esp)
 869:	e8 be fd ff ff       	call   62c <putc>
 86e:	eb 28                	jmp    898 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 870:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 877:	00 
 878:	8b 45 08             	mov    0x8(%ebp),%eax
 87b:	89 04 24             	mov    %eax,(%esp)
 87e:	e8 a9 fd ff ff       	call   62c <putc>
        putc(fd, c);
 883:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 886:	0f be c0             	movsbl %al,%eax
 889:	89 44 24 04          	mov    %eax,0x4(%esp)
 88d:	8b 45 08             	mov    0x8(%ebp),%eax
 890:	89 04 24             	mov    %eax,(%esp)
 893:	e8 94 fd ff ff       	call   62c <putc>
      }
      state = 0;
 898:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 89f:	ff 45 f0             	incl   -0x10(%ebp)
 8a2:	8b 55 0c             	mov    0xc(%ebp),%edx
 8a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8a8:	01 d0                	add    %edx,%eax
 8aa:	8a 00                	mov    (%eax),%al
 8ac:	84 c0                	test   %al,%al
 8ae:	0f 85 77 fe ff ff    	jne    72b <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 8b4:	c9                   	leave  
 8b5:	c3                   	ret    
 8b6:	90                   	nop
 8b7:	90                   	nop

000008b8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8b8:	55                   	push   %ebp
 8b9:	89 e5                	mov    %esp,%ebp
 8bb:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8be:	8b 45 08             	mov    0x8(%ebp),%eax
 8c1:	83 e8 08             	sub    $0x8,%eax
 8c4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8c7:	a1 68 0e 00 00       	mov    0xe68,%eax
 8cc:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8cf:	eb 24                	jmp    8f5 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d4:	8b 00                	mov    (%eax),%eax
 8d6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8d9:	77 12                	ja     8ed <free+0x35>
 8db:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8de:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8e1:	77 24                	ja     907 <free+0x4f>
 8e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e6:	8b 00                	mov    (%eax),%eax
 8e8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8eb:	77 1a                	ja     907 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f0:	8b 00                	mov    (%eax),%eax
 8f2:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8f5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8f8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8fb:	76 d4                	jbe    8d1 <free+0x19>
 8fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 900:	8b 00                	mov    (%eax),%eax
 902:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 905:	76 ca                	jbe    8d1 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 907:	8b 45 f8             	mov    -0x8(%ebp),%eax
 90a:	8b 40 04             	mov    0x4(%eax),%eax
 90d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 914:	8b 45 f8             	mov    -0x8(%ebp),%eax
 917:	01 c2                	add    %eax,%edx
 919:	8b 45 fc             	mov    -0x4(%ebp),%eax
 91c:	8b 00                	mov    (%eax),%eax
 91e:	39 c2                	cmp    %eax,%edx
 920:	75 24                	jne    946 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 922:	8b 45 f8             	mov    -0x8(%ebp),%eax
 925:	8b 50 04             	mov    0x4(%eax),%edx
 928:	8b 45 fc             	mov    -0x4(%ebp),%eax
 92b:	8b 00                	mov    (%eax),%eax
 92d:	8b 40 04             	mov    0x4(%eax),%eax
 930:	01 c2                	add    %eax,%edx
 932:	8b 45 f8             	mov    -0x8(%ebp),%eax
 935:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 938:	8b 45 fc             	mov    -0x4(%ebp),%eax
 93b:	8b 00                	mov    (%eax),%eax
 93d:	8b 10                	mov    (%eax),%edx
 93f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 942:	89 10                	mov    %edx,(%eax)
 944:	eb 0a                	jmp    950 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 946:	8b 45 fc             	mov    -0x4(%ebp),%eax
 949:	8b 10                	mov    (%eax),%edx
 94b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 94e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 950:	8b 45 fc             	mov    -0x4(%ebp),%eax
 953:	8b 40 04             	mov    0x4(%eax),%eax
 956:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 95d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 960:	01 d0                	add    %edx,%eax
 962:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 965:	75 20                	jne    987 <free+0xcf>
    p->s.size += bp->s.size;
 967:	8b 45 fc             	mov    -0x4(%ebp),%eax
 96a:	8b 50 04             	mov    0x4(%eax),%edx
 96d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 970:	8b 40 04             	mov    0x4(%eax),%eax
 973:	01 c2                	add    %eax,%edx
 975:	8b 45 fc             	mov    -0x4(%ebp),%eax
 978:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 97b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 97e:	8b 10                	mov    (%eax),%edx
 980:	8b 45 fc             	mov    -0x4(%ebp),%eax
 983:	89 10                	mov    %edx,(%eax)
 985:	eb 08                	jmp    98f <free+0xd7>
  } else
    p->s.ptr = bp;
 987:	8b 45 fc             	mov    -0x4(%ebp),%eax
 98a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 98d:	89 10                	mov    %edx,(%eax)
  freep = p;
 98f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 992:	a3 68 0e 00 00       	mov    %eax,0xe68
}
 997:	c9                   	leave  
 998:	c3                   	ret    

00000999 <morecore>:

static Header*
morecore(uint nu)
{
 999:	55                   	push   %ebp
 99a:	89 e5                	mov    %esp,%ebp
 99c:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 99f:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 9a6:	77 07                	ja     9af <morecore+0x16>
    nu = 4096;
 9a8:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 9af:	8b 45 08             	mov    0x8(%ebp),%eax
 9b2:	c1 e0 03             	shl    $0x3,%eax
 9b5:	89 04 24             	mov    %eax,(%esp)
 9b8:	e8 3f fc ff ff       	call   5fc <sbrk>
 9bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 9c0:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 9c4:	75 07                	jne    9cd <morecore+0x34>
    return 0;
 9c6:	b8 00 00 00 00       	mov    $0x0,%eax
 9cb:	eb 22                	jmp    9ef <morecore+0x56>
  hp = (Header*)p;
 9cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 9d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9d6:	8b 55 08             	mov    0x8(%ebp),%edx
 9d9:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 9dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9df:	83 c0 08             	add    $0x8,%eax
 9e2:	89 04 24             	mov    %eax,(%esp)
 9e5:	e8 ce fe ff ff       	call   8b8 <free>
  return freep;
 9ea:	a1 68 0e 00 00       	mov    0xe68,%eax
}
 9ef:	c9                   	leave  
 9f0:	c3                   	ret    

000009f1 <malloc>:

void*
malloc(uint nbytes)
{
 9f1:	55                   	push   %ebp
 9f2:	89 e5                	mov    %esp,%ebp
 9f4:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9f7:	8b 45 08             	mov    0x8(%ebp),%eax
 9fa:	83 c0 07             	add    $0x7,%eax
 9fd:	c1 e8 03             	shr    $0x3,%eax
 a00:	40                   	inc    %eax
 a01:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a04:	a1 68 0e 00 00       	mov    0xe68,%eax
 a09:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a0c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a10:	75 23                	jne    a35 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 a12:	c7 45 f0 60 0e 00 00 	movl   $0xe60,-0x10(%ebp)
 a19:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a1c:	a3 68 0e 00 00       	mov    %eax,0xe68
 a21:	a1 68 0e 00 00       	mov    0xe68,%eax
 a26:	a3 60 0e 00 00       	mov    %eax,0xe60
    base.s.size = 0;
 a2b:	c7 05 64 0e 00 00 00 	movl   $0x0,0xe64
 a32:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a35:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a38:	8b 00                	mov    (%eax),%eax
 a3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a40:	8b 40 04             	mov    0x4(%eax),%eax
 a43:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a46:	72 4d                	jb     a95 <malloc+0xa4>
      if(p->s.size == nunits)
 a48:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a4b:	8b 40 04             	mov    0x4(%eax),%eax
 a4e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a51:	75 0c                	jne    a5f <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 a53:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a56:	8b 10                	mov    (%eax),%edx
 a58:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a5b:	89 10                	mov    %edx,(%eax)
 a5d:	eb 26                	jmp    a85 <malloc+0x94>
      else {
        p->s.size -= nunits;
 a5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a62:	8b 40 04             	mov    0x4(%eax),%eax
 a65:	2b 45 ec             	sub    -0x14(%ebp),%eax
 a68:	89 c2                	mov    %eax,%edx
 a6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a6d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a70:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a73:	8b 40 04             	mov    0x4(%eax),%eax
 a76:	c1 e0 03             	shl    $0x3,%eax
 a79:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a7f:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a82:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a85:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a88:	a3 68 0e 00 00       	mov    %eax,0xe68
      return (void*)(p + 1);
 a8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a90:	83 c0 08             	add    $0x8,%eax
 a93:	eb 38                	jmp    acd <malloc+0xdc>
    }
    if(p == freep)
 a95:	a1 68 0e 00 00       	mov    0xe68,%eax
 a9a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a9d:	75 1b                	jne    aba <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 a9f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 aa2:	89 04 24             	mov    %eax,(%esp)
 aa5:	e8 ef fe ff ff       	call   999 <morecore>
 aaa:	89 45 f4             	mov    %eax,-0xc(%ebp)
 aad:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 ab1:	75 07                	jne    aba <malloc+0xc9>
        return 0;
 ab3:	b8 00 00 00 00       	mov    $0x0,%eax
 ab8:	eb 13                	jmp    acd <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
 abd:	89 45 f0             	mov    %eax,-0x10(%ebp)
 ac0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ac3:	8b 00                	mov    (%eax),%eax
 ac5:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 ac8:	e9 70 ff ff ff       	jmp    a3d <malloc+0x4c>
}
 acd:	c9                   	leave  
 ace:	c3                   	ret    
