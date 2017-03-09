
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4 0f                	in     $0xf,%al

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 70 c6 10 80       	mov    $0x8010c670,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 a6 37 10 80       	mov    $0x801037a6,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	c7 44 24 04 40 85 10 	movl   $0x80108540,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 80 c6 10 80 	movl   $0x8010c680,(%esp)
80100049:	e8 b8 4e 00 00       	call   80104f06 <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 cc 0d 11 80 7c 	movl   $0x80110d7c,0x80110dcc
80100055:	0d 11 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 d0 0d 11 80 7c 	movl   $0x80110d7c,0x80110dd0
8010005f:	0d 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 b4 c6 10 80 	movl   $0x8010c6b4,-0xc(%ebp)
80100069:	eb 46                	jmp    801000b1 <binit+0x7d>
    b->next = bcache.head.next;
8010006b:	8b 15 d0 0d 11 80    	mov    0x80110dd0,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 50 7c 0d 11 80 	movl   $0x80110d7c,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	83 c0 0c             	add    $0xc,%eax
80100087:	c7 44 24 04 47 85 10 	movl   $0x80108547,0x4(%esp)
8010008e:	80 
8010008f:	89 04 24             	mov    %eax,(%esp)
80100092:	e8 31 4d 00 00       	call   80104dc8 <initsleeplock>
    bcache.head.next->prev = b;
80100097:	a1 d0 0d 11 80       	mov    0x80110dd0,%eax
8010009c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010009f:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000a5:	a3 d0 0d 11 80       	mov    %eax,0x80110dd0

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000aa:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000b1:	81 7d f4 7c 0d 11 80 	cmpl   $0x80110d7c,-0xc(%ebp)
801000b8:	72 b1                	jb     8010006b <binit+0x37>
    b->prev = &bcache.head;
    initsleeplock(&b->lock, "buffer");
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000ba:	c9                   	leave  
801000bb:	c3                   	ret    

801000bc <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000bc:	55                   	push   %ebp
801000bd:	89 e5                	mov    %esp,%ebp
801000bf:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000c2:	c7 04 24 80 c6 10 80 	movl   $0x8010c680,(%esp)
801000c9:	e8 59 4e 00 00       	call   80104f27 <acquire>

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000ce:	a1 d0 0d 11 80       	mov    0x80110dd0,%eax
801000d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000d6:	eb 50                	jmp    80100128 <bget+0x6c>
    if(b->dev == dev && b->blockno == blockno){
801000d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000db:	8b 40 04             	mov    0x4(%eax),%eax
801000de:	3b 45 08             	cmp    0x8(%ebp),%eax
801000e1:	75 3c                	jne    8010011f <bget+0x63>
801000e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e6:	8b 40 08             	mov    0x8(%eax),%eax
801000e9:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000ec:	75 31                	jne    8010011f <bget+0x63>
      b->refcnt++;
801000ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f1:	8b 40 4c             	mov    0x4c(%eax),%eax
801000f4:	8d 50 01             	lea    0x1(%eax),%edx
801000f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000fa:	89 50 4c             	mov    %edx,0x4c(%eax)
      release(&bcache.lock);
801000fd:	c7 04 24 80 c6 10 80 	movl   $0x8010c680,(%esp)
80100104:	e8 85 4e 00 00       	call   80104f8e <release>
      acquiresleep(&b->lock);
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	83 c0 0c             	add    $0xc,%eax
8010010f:	89 04 24             	mov    %eax,(%esp)
80100112:	e8 eb 4c 00 00       	call   80104e02 <acquiresleep>
      return b;
80100117:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011a:	e9 94 00 00 00       	jmp    801001b3 <bget+0xf7>
  struct buf *b;

  acquire(&bcache.lock);

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
8010011f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100122:	8b 40 54             	mov    0x54(%eax),%eax
80100125:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100128:	81 7d f4 7c 0d 11 80 	cmpl   $0x80110d7c,-0xc(%ebp)
8010012f:	75 a7                	jne    801000d8 <bget+0x1c>
  }

  // Not cached; recycle some unused buffer and clean buffer
  // "clean" because B_DIRTY and not locked means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100131:	a1 cc 0d 11 80       	mov    0x80110dcc,%eax
80100136:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100139:	eb 63                	jmp    8010019e <bget+0xe2>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
8010013b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010013e:	8b 40 4c             	mov    0x4c(%eax),%eax
80100141:	85 c0                	test   %eax,%eax
80100143:	75 50                	jne    80100195 <bget+0xd9>
80100145:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100148:	8b 00                	mov    (%eax),%eax
8010014a:	83 e0 04             	and    $0x4,%eax
8010014d:	85 c0                	test   %eax,%eax
8010014f:	75 44                	jne    80100195 <bget+0xd9>
      b->dev = dev;
80100151:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100154:	8b 55 08             	mov    0x8(%ebp),%edx
80100157:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	8b 55 0c             	mov    0xc(%ebp),%edx
80100160:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = 0;
80100163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100166:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      b->refcnt = 1;
8010016c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016f:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
      release(&bcache.lock);
80100176:	c7 04 24 80 c6 10 80 	movl   $0x8010c680,(%esp)
8010017d:	e8 0c 4e 00 00       	call   80104f8e <release>
      acquiresleep(&b->lock);
80100182:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100185:	83 c0 0c             	add    $0xc,%eax
80100188:	89 04 24             	mov    %eax,(%esp)
8010018b:	e8 72 4c 00 00       	call   80104e02 <acquiresleep>
      return b;
80100190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100193:	eb 1e                	jmp    801001b3 <bget+0xf7>
  }

  // Not cached; recycle some unused buffer and clean buffer
  // "clean" because B_DIRTY and not locked means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100198:	8b 40 50             	mov    0x50(%eax),%eax
8010019b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010019e:	81 7d f4 7c 0d 11 80 	cmpl   $0x80110d7c,-0xc(%ebp)
801001a5:	75 94                	jne    8010013b <bget+0x7f>
      release(&bcache.lock);
      acquiresleep(&b->lock);
      return b;
    }
  }
  panic("bget: no buffers");
801001a7:	c7 04 24 4e 85 10 80 	movl   $0x8010854e,(%esp)
801001ae:	e8 a1 03 00 00       	call   80100554 <panic>
}
801001b3:	c9                   	leave  
801001b4:	c3                   	ret    

801001b5 <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001b5:	55                   	push   %ebp
801001b6:	89 e5                	mov    %esp,%ebp
801001b8:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001bb:	8b 45 0c             	mov    0xc(%ebp),%eax
801001be:	89 44 24 04          	mov    %eax,0x4(%esp)
801001c2:	8b 45 08             	mov    0x8(%ebp),%eax
801001c5:	89 04 24             	mov    %eax,(%esp)
801001c8:	e8 ef fe ff ff       	call   801000bc <bget>
801001cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID)) {
801001d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d3:	8b 00                	mov    (%eax),%eax
801001d5:	83 e0 02             	and    $0x2,%eax
801001d8:	85 c0                	test   %eax,%eax
801001da:	75 0b                	jne    801001e7 <bread+0x32>
    iderw(b);
801001dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001df:	89 04 24             	mov    %eax,(%esp)
801001e2:	e8 46 26 00 00       	call   8010282d <iderw>
  }
  return b;
801001e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001ea:	c9                   	leave  
801001eb:	c3                   	ret    

801001ec <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
801001ec:	55                   	push   %ebp
801001ed:	89 e5                	mov    %esp,%ebp
801001ef:	83 ec 18             	sub    $0x18,%esp
  if(!holdingsleep(&b->lock))
801001f2:	8b 45 08             	mov    0x8(%ebp),%eax
801001f5:	83 c0 0c             	add    $0xc,%eax
801001f8:	89 04 24             	mov    %eax,(%esp)
801001fb:	e8 a0 4c 00 00       	call   80104ea0 <holdingsleep>
80100200:	85 c0                	test   %eax,%eax
80100202:	75 0c                	jne    80100210 <bwrite+0x24>
    panic("bwrite");
80100204:	c7 04 24 5f 85 10 80 	movl   $0x8010855f,(%esp)
8010020b:	e8 44 03 00 00       	call   80100554 <panic>
  b->flags |= B_DIRTY;
80100210:	8b 45 08             	mov    0x8(%ebp),%eax
80100213:	8b 00                	mov    (%eax),%eax
80100215:	83 c8 04             	or     $0x4,%eax
80100218:	89 c2                	mov    %eax,%edx
8010021a:	8b 45 08             	mov    0x8(%ebp),%eax
8010021d:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010021f:	8b 45 08             	mov    0x8(%ebp),%eax
80100222:	89 04 24             	mov    %eax,(%esp)
80100225:	e8 03 26 00 00       	call   8010282d <iderw>
}
8010022a:	c9                   	leave  
8010022b:	c3                   	ret    

8010022c <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
8010022c:	55                   	push   %ebp
8010022d:	89 e5                	mov    %esp,%ebp
8010022f:	83 ec 18             	sub    $0x18,%esp
  if(!holdingsleep(&b->lock))
80100232:	8b 45 08             	mov    0x8(%ebp),%eax
80100235:	83 c0 0c             	add    $0xc,%eax
80100238:	89 04 24             	mov    %eax,(%esp)
8010023b:	e8 60 4c 00 00       	call   80104ea0 <holdingsleep>
80100240:	85 c0                	test   %eax,%eax
80100242:	75 0c                	jne    80100250 <brelse+0x24>
    panic("brelse");
80100244:	c7 04 24 66 85 10 80 	movl   $0x80108566,(%esp)
8010024b:	e8 04 03 00 00       	call   80100554 <panic>

  releasesleep(&b->lock);
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	83 c0 0c             	add    $0xc,%eax
80100256:	89 04 24             	mov    %eax,(%esp)
80100259:	e8 00 4c 00 00       	call   80104e5e <releasesleep>

  acquire(&bcache.lock);
8010025e:	c7 04 24 80 c6 10 80 	movl   $0x8010c680,(%esp)
80100265:	e8 bd 4c 00 00       	call   80104f27 <acquire>
  b->refcnt--;
8010026a:	8b 45 08             	mov    0x8(%ebp),%eax
8010026d:	8b 40 4c             	mov    0x4c(%eax),%eax
80100270:	8d 50 ff             	lea    -0x1(%eax),%edx
80100273:	8b 45 08             	mov    0x8(%ebp),%eax
80100276:	89 50 4c             	mov    %edx,0x4c(%eax)
  if (b->refcnt == 0) {
80100279:	8b 45 08             	mov    0x8(%ebp),%eax
8010027c:	8b 40 4c             	mov    0x4c(%eax),%eax
8010027f:	85 c0                	test   %eax,%eax
80100281:	75 47                	jne    801002ca <brelse+0x9e>
    // no one is waiting for it.
    b->next->prev = b->prev;
80100283:	8b 45 08             	mov    0x8(%ebp),%eax
80100286:	8b 40 54             	mov    0x54(%eax),%eax
80100289:	8b 55 08             	mov    0x8(%ebp),%edx
8010028c:	8b 52 50             	mov    0x50(%edx),%edx
8010028f:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
80100292:	8b 45 08             	mov    0x8(%ebp),%eax
80100295:	8b 40 50             	mov    0x50(%eax),%eax
80100298:	8b 55 08             	mov    0x8(%ebp),%edx
8010029b:	8b 52 54             	mov    0x54(%edx),%edx
8010029e:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
801002a1:	8b 15 d0 0d 11 80    	mov    0x80110dd0,%edx
801002a7:	8b 45 08             	mov    0x8(%ebp),%eax
801002aa:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801002ad:	8b 45 08             	mov    0x8(%ebp),%eax
801002b0:	c7 40 50 7c 0d 11 80 	movl   $0x80110d7c,0x50(%eax)
    bcache.head.next->prev = b;
801002b7:	a1 d0 0d 11 80       	mov    0x80110dd0,%eax
801002bc:	8b 55 08             	mov    0x8(%ebp),%edx
801002bf:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801002c2:	8b 45 08             	mov    0x8(%ebp),%eax
801002c5:	a3 d0 0d 11 80       	mov    %eax,0x80110dd0
  }
  
  release(&bcache.lock);
801002ca:	c7 04 24 80 c6 10 80 	movl   $0x8010c680,(%esp)
801002d1:	e8 b8 4c 00 00       	call   80104f8e <release>
}
801002d6:	c9                   	leave  
801002d7:	c3                   	ret    

801002d8 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002d8:	55                   	push   %ebp
801002d9:	89 e5                	mov    %esp,%ebp
801002db:	83 ec 14             	sub    $0x14,%esp
801002de:	8b 45 08             	mov    0x8(%ebp),%eax
801002e1:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801002e8:	89 c2                	mov    %eax,%edx
801002ea:	ec                   	in     (%dx),%al
801002eb:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002ee:	8a 45 ff             	mov    -0x1(%ebp),%al
}
801002f1:	c9                   	leave  
801002f2:	c3                   	ret    

801002f3 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002f3:	55                   	push   %ebp
801002f4:	89 e5                	mov    %esp,%ebp
801002f6:	83 ec 08             	sub    $0x8,%esp
801002f9:	8b 45 08             	mov    0x8(%ebp),%eax
801002fc:	8b 55 0c             	mov    0xc(%ebp),%edx
801002ff:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80100303:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100306:	8a 45 f8             	mov    -0x8(%ebp),%al
80100309:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010030c:	ee                   	out    %al,(%dx)
}
8010030d:	c9                   	leave  
8010030e:	c3                   	ret    

8010030f <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
8010030f:	55                   	push   %ebp
80100310:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100312:	fa                   	cli    
}
80100313:	5d                   	pop    %ebp
80100314:	c3                   	ret    

80100315 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100315:	55                   	push   %ebp
80100316:	89 e5                	mov    %esp,%ebp
80100318:	56                   	push   %esi
80100319:	53                   	push   %ebx
8010031a:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010031d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100321:	74 1c                	je     8010033f <printint+0x2a>
80100323:	8b 45 08             	mov    0x8(%ebp),%eax
80100326:	c1 e8 1f             	shr    $0x1f,%eax
80100329:	0f b6 c0             	movzbl %al,%eax
8010032c:	89 45 10             	mov    %eax,0x10(%ebp)
8010032f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100333:	74 0a                	je     8010033f <printint+0x2a>
    x = -xx;
80100335:	8b 45 08             	mov    0x8(%ebp),%eax
80100338:	f7 d8                	neg    %eax
8010033a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010033d:	eb 06                	jmp    80100345 <printint+0x30>
  else
    x = xx;
8010033f:	8b 45 08             	mov    0x8(%ebp),%eax
80100342:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100345:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010034c:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010034f:	8d 41 01             	lea    0x1(%ecx),%eax
80100352:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100355:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100358:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010035b:	ba 00 00 00 00       	mov    $0x0,%edx
80100360:	f7 f3                	div    %ebx
80100362:	89 d0                	mov    %edx,%eax
80100364:	8a 80 04 90 10 80    	mov    -0x7fef6ffc(%eax),%al
8010036a:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
8010036e:	8b 75 0c             	mov    0xc(%ebp),%esi
80100371:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100374:	ba 00 00 00 00       	mov    $0x0,%edx
80100379:	f7 f6                	div    %esi
8010037b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010037e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100382:	75 c8                	jne    8010034c <printint+0x37>

  if(sign)
80100384:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100388:	74 10                	je     8010039a <printint+0x85>
    buf[i++] = '-';
8010038a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038d:	8d 50 01             	lea    0x1(%eax),%edx
80100390:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100393:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
80100398:	eb 17                	jmp    801003b1 <printint+0x9c>
8010039a:	eb 15                	jmp    801003b1 <printint+0x9c>
    consputc(buf[i]);
8010039c:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010039f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003a2:	01 d0                	add    %edx,%eax
801003a4:	8a 00                	mov    (%eax),%al
801003a6:	0f be c0             	movsbl %al,%eax
801003a9:	89 04 24             	mov    %eax,(%esp)
801003ac:	e8 bd 03 00 00       	call   8010076e <consputc>
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
801003b1:	ff 4d f4             	decl   -0xc(%ebp)
801003b4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003b8:	79 e2                	jns    8010039c <printint+0x87>
    consputc(buf[i]);
}
801003ba:	83 c4 30             	add    $0x30,%esp
801003bd:	5b                   	pop    %ebx
801003be:	5e                   	pop    %esi
801003bf:	5d                   	pop    %ebp
801003c0:	c3                   	ret    

801003c1 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003c1:	55                   	push   %ebp
801003c2:	89 e5                	mov    %esp,%ebp
801003c4:	83 ec 38             	sub    $0x38,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003c7:	a1 14 b6 10 80       	mov    0x8010b614,%eax
801003cc:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003cf:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d3:	74 0c                	je     801003e1 <cprintf+0x20>
    acquire(&cons.lock);
801003d5:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
801003dc:	e8 46 4b 00 00       	call   80104f27 <acquire>

  if (fmt == 0)
801003e1:	8b 45 08             	mov    0x8(%ebp),%eax
801003e4:	85 c0                	test   %eax,%eax
801003e6:	75 0c                	jne    801003f4 <cprintf+0x33>
    panic("null fmt");
801003e8:	c7 04 24 6d 85 10 80 	movl   $0x8010856d,(%esp)
801003ef:	e8 60 01 00 00       	call   80100554 <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003f4:	8d 45 0c             	lea    0xc(%ebp),%eax
801003f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801003fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100401:	e9 1b 01 00 00       	jmp    80100521 <cprintf+0x160>
    if(c != '%'){
80100406:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
8010040a:	74 10                	je     8010041c <cprintf+0x5b>
      consputc(c);
8010040c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010040f:	89 04 24             	mov    %eax,(%esp)
80100412:	e8 57 03 00 00       	call   8010076e <consputc>
      continue;
80100417:	e9 02 01 00 00       	jmp    8010051e <cprintf+0x15d>
    }
    c = fmt[++i] & 0xff;
8010041c:	8b 55 08             	mov    0x8(%ebp),%edx
8010041f:	ff 45 f4             	incl   -0xc(%ebp)
80100422:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100425:	01 d0                	add    %edx,%eax
80100427:	8a 00                	mov    (%eax),%al
80100429:	0f be c0             	movsbl %al,%eax
8010042c:	25 ff 00 00 00       	and    $0xff,%eax
80100431:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100434:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100438:	75 05                	jne    8010043f <cprintf+0x7e>
      break;
8010043a:	e9 01 01 00 00       	jmp    80100540 <cprintf+0x17f>
    switch(c){
8010043f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100442:	83 f8 70             	cmp    $0x70,%eax
80100445:	74 4f                	je     80100496 <cprintf+0xd5>
80100447:	83 f8 70             	cmp    $0x70,%eax
8010044a:	7f 13                	jg     8010045f <cprintf+0x9e>
8010044c:	83 f8 25             	cmp    $0x25,%eax
8010044f:	0f 84 a3 00 00 00    	je     801004f8 <cprintf+0x137>
80100455:	83 f8 64             	cmp    $0x64,%eax
80100458:	74 14                	je     8010046e <cprintf+0xad>
8010045a:	e9 a7 00 00 00       	jmp    80100506 <cprintf+0x145>
8010045f:	83 f8 73             	cmp    $0x73,%eax
80100462:	74 57                	je     801004bb <cprintf+0xfa>
80100464:	83 f8 78             	cmp    $0x78,%eax
80100467:	74 2d                	je     80100496 <cprintf+0xd5>
80100469:	e9 98 00 00 00       	jmp    80100506 <cprintf+0x145>
    case 'd':
      printint(*argp++, 10, 1);
8010046e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100471:	8d 50 04             	lea    0x4(%eax),%edx
80100474:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100477:	8b 00                	mov    (%eax),%eax
80100479:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80100480:	00 
80100481:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80100488:	00 
80100489:	89 04 24             	mov    %eax,(%esp)
8010048c:	e8 84 fe ff ff       	call   80100315 <printint>
      break;
80100491:	e9 88 00 00 00       	jmp    8010051e <cprintf+0x15d>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
80100496:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100499:	8d 50 04             	lea    0x4(%eax),%edx
8010049c:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010049f:	8b 00                	mov    (%eax),%eax
801004a1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801004a8:	00 
801004a9:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
801004b0:	00 
801004b1:	89 04 24             	mov    %eax,(%esp)
801004b4:	e8 5c fe ff ff       	call   80100315 <printint>
      break;
801004b9:	eb 63                	jmp    8010051e <cprintf+0x15d>
    case 's':
      if((s = (char*)*argp++) == 0)
801004bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004be:	8d 50 04             	lea    0x4(%eax),%edx
801004c1:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c4:	8b 00                	mov    (%eax),%eax
801004c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004c9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004cd:	75 09                	jne    801004d8 <cprintf+0x117>
        s = "(null)";
801004cf:	c7 45 ec 76 85 10 80 	movl   $0x80108576,-0x14(%ebp)
      for(; *s; s++)
801004d6:	eb 15                	jmp    801004ed <cprintf+0x12c>
801004d8:	eb 13                	jmp    801004ed <cprintf+0x12c>
        consputc(*s);
801004da:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004dd:	8a 00                	mov    (%eax),%al
801004df:	0f be c0             	movsbl %al,%eax
801004e2:	89 04 24             	mov    %eax,(%esp)
801004e5:	e8 84 02 00 00       	call   8010076e <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004ea:	ff 45 ec             	incl   -0x14(%ebp)
801004ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004f0:	8a 00                	mov    (%eax),%al
801004f2:	84 c0                	test   %al,%al
801004f4:	75 e4                	jne    801004da <cprintf+0x119>
        consputc(*s);
      break;
801004f6:	eb 26                	jmp    8010051e <cprintf+0x15d>
    case '%':
      consputc('%');
801004f8:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004ff:	e8 6a 02 00 00       	call   8010076e <consputc>
      break;
80100504:	eb 18                	jmp    8010051e <cprintf+0x15d>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
80100506:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
8010050d:	e8 5c 02 00 00       	call   8010076e <consputc>
      consputc(c);
80100512:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100515:	89 04 24             	mov    %eax,(%esp)
80100518:	e8 51 02 00 00       	call   8010076e <consputc>
      break;
8010051d:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010051e:	ff 45 f4             	incl   -0xc(%ebp)
80100521:	8b 55 08             	mov    0x8(%ebp),%edx
80100524:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100527:	01 d0                	add    %edx,%eax
80100529:	8a 00                	mov    (%eax),%al
8010052b:	0f be c0             	movsbl %al,%eax
8010052e:	25 ff 00 00 00       	and    $0xff,%eax
80100533:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100536:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010053a:	0f 85 c6 fe ff ff    	jne    80100406 <cprintf+0x45>
      consputc(c);
      break;
    }
  }

  if(locking)
80100540:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100544:	74 0c                	je     80100552 <cprintf+0x191>
    release(&cons.lock);
80100546:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
8010054d:	e8 3c 4a 00 00       	call   80104f8e <release>
}
80100552:	c9                   	leave  
80100553:	c3                   	ret    

80100554 <panic>:

void
panic(char *s)
{
80100554:	55                   	push   %ebp
80100555:	89 e5                	mov    %esp,%ebp
80100557:	83 ec 48             	sub    $0x48,%esp
  int i;
  uint pcs[10];

  cli();
8010055a:	e8 b0 fd ff ff       	call   8010030f <cli>
  cons.locking = 0;
8010055f:	c7 05 14 b6 10 80 00 	movl   $0x0,0x8010b614
80100566:	00 00 00 
  cprintf("cpu with apicid %d: panic: ", cpu->apicid);
80100569:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010056f:	8a 00                	mov    (%eax),%al
80100571:	0f b6 c0             	movzbl %al,%eax
80100574:	89 44 24 04          	mov    %eax,0x4(%esp)
80100578:	c7 04 24 7d 85 10 80 	movl   $0x8010857d,(%esp)
8010057f:	e8 3d fe ff ff       	call   801003c1 <cprintf>
  cprintf(s);
80100584:	8b 45 08             	mov    0x8(%ebp),%eax
80100587:	89 04 24             	mov    %eax,(%esp)
8010058a:	e8 32 fe ff ff       	call   801003c1 <cprintf>
  cprintf("\n");
8010058f:	c7 04 24 99 85 10 80 	movl   $0x80108599,(%esp)
80100596:	e8 26 fe ff ff       	call   801003c1 <cprintf>
  getcallerpcs(&s, pcs);
8010059b:	8d 45 cc             	lea    -0x34(%ebp),%eax
8010059e:	89 44 24 04          	mov    %eax,0x4(%esp)
801005a2:	8d 45 08             	lea    0x8(%ebp),%eax
801005a5:	89 04 24             	mov    %eax,(%esp)
801005a8:	e8 2e 4a 00 00       	call   80104fdb <getcallerpcs>
  for(i=0; i<10; i++)
801005ad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005b4:	eb 1a                	jmp    801005d0 <panic+0x7c>
    cprintf(" %p", pcs[i]);
801005b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005b9:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005bd:	89 44 24 04          	mov    %eax,0x4(%esp)
801005c1:	c7 04 24 9b 85 10 80 	movl   $0x8010859b,(%esp)
801005c8:	e8 f4 fd ff ff       	call   801003c1 <cprintf>
  cons.locking = 0;
  cprintf("cpu with apicid %d: panic: ", cpu->apicid);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005cd:	ff 45 f4             	incl   -0xc(%ebp)
801005d0:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005d4:	7e e0                	jle    801005b6 <panic+0x62>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005d6:	c7 05 c0 b5 10 80 01 	movl   $0x1,0x8010b5c0
801005dd:	00 00 00 
  for(;;)
    ;
801005e0:	eb fe                	jmp    801005e0 <panic+0x8c>

801005e2 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801005e2:	55                   	push   %ebp
801005e3:	89 e5                	mov    %esp,%ebp
801005e5:	83 ec 28             	sub    $0x28,%esp
  int pos;

  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801005e8:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801005ef:	00 
801005f0:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801005f7:	e8 f7 fc ff ff       	call   801002f3 <outb>
  pos = inb(CRTPORT+1) << 8;
801005fc:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100603:	e8 d0 fc ff ff       	call   801002d8 <inb>
80100608:	0f b6 c0             	movzbl %al,%eax
8010060b:	c1 e0 08             	shl    $0x8,%eax
8010060e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
80100611:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100618:	00 
80100619:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100620:	e8 ce fc ff ff       	call   801002f3 <outb>
  pos |= inb(CRTPORT+1);
80100625:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
8010062c:	e8 a7 fc ff ff       	call   801002d8 <inb>
80100631:	0f b6 c0             	movzbl %al,%eax
80100634:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
80100637:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
8010063b:	75 1b                	jne    80100658 <cgaputc+0x76>
    pos += 80 - pos%80;
8010063d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100640:	b9 50 00 00 00       	mov    $0x50,%ecx
80100645:	99                   	cltd   
80100646:	f7 f9                	idiv   %ecx
80100648:	89 d0                	mov    %edx,%eax
8010064a:	ba 50 00 00 00       	mov    $0x50,%edx
8010064f:	29 c2                	sub    %eax,%edx
80100651:	89 d0                	mov    %edx,%eax
80100653:	01 45 f4             	add    %eax,-0xc(%ebp)
80100656:	eb 34                	jmp    8010068c <cgaputc+0xaa>
  else if(c == BACKSPACE){
80100658:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010065f:	75 0b                	jne    8010066c <cgaputc+0x8a>
    if(pos > 0) --pos;
80100661:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100665:	7e 25                	jle    8010068c <cgaputc+0xaa>
80100667:	ff 4d f4             	decl   -0xc(%ebp)
8010066a:	eb 20                	jmp    8010068c <cgaputc+0xaa>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010066c:	8b 0d 00 90 10 80    	mov    0x80109000,%ecx
80100672:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100675:	8d 50 01             	lea    0x1(%eax),%edx
80100678:	89 55 f4             	mov    %edx,-0xc(%ebp)
8010067b:	01 c0                	add    %eax,%eax
8010067d:	8d 14 01             	lea    (%ecx,%eax,1),%edx
80100680:	8b 45 08             	mov    0x8(%ebp),%eax
80100683:	0f b6 c0             	movzbl %al,%eax
80100686:	80 cc 07             	or     $0x7,%ah
80100689:	66 89 02             	mov    %ax,(%edx)

  if(pos < 0 || pos > 25*80)
8010068c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100690:	78 09                	js     8010069b <cgaputc+0xb9>
80100692:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
80100699:	7e 0c                	jle    801006a7 <cgaputc+0xc5>
    panic("pos under/overflow");
8010069b:	c7 04 24 9f 85 10 80 	movl   $0x8010859f,(%esp)
801006a2:	e8 ad fe ff ff       	call   80100554 <panic>

  if((pos/80) >= 24){  // Scroll up.
801006a7:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006ae:	7e 53                	jle    80100703 <cgaputc+0x121>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006b0:	a1 00 90 10 80       	mov    0x80109000,%eax
801006b5:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006bb:	a1 00 90 10 80       	mov    0x80109000,%eax
801006c0:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
801006c7:	00 
801006c8:	89 54 24 04          	mov    %edx,0x4(%esp)
801006cc:	89 04 24             	mov    %eax,(%esp)
801006cf:	e8 7f 4b 00 00       	call   80105253 <memmove>
    pos -= 80;
801006d4:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006d8:	b8 80 07 00 00       	mov    $0x780,%eax
801006dd:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006e0:	01 c0                	add    %eax,%eax
801006e2:	8b 0d 00 90 10 80    	mov    0x80109000,%ecx
801006e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801006eb:	01 d2                	add    %edx,%edx
801006ed:	01 ca                	add    %ecx,%edx
801006ef:	89 44 24 08          	mov    %eax,0x8(%esp)
801006f3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801006fa:	00 
801006fb:	89 14 24             	mov    %edx,(%esp)
801006fe:	e8 87 4a 00 00       	call   8010518a <memset>
  }

  outb(CRTPORT, 14);
80100703:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
8010070a:	00 
8010070b:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100712:	e8 dc fb ff ff       	call   801002f3 <outb>
  outb(CRTPORT+1, pos>>8);
80100717:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010071a:	c1 f8 08             	sar    $0x8,%eax
8010071d:	0f b6 c0             	movzbl %al,%eax
80100720:	89 44 24 04          	mov    %eax,0x4(%esp)
80100724:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
8010072b:	e8 c3 fb ff ff       	call   801002f3 <outb>
  outb(CRTPORT, 15);
80100730:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100737:	00 
80100738:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
8010073f:	e8 af fb ff ff       	call   801002f3 <outb>
  outb(CRTPORT+1, pos);
80100744:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100747:	0f b6 c0             	movzbl %al,%eax
8010074a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010074e:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100755:	e8 99 fb ff ff       	call   801002f3 <outb>
  crt[pos] = ' ' | 0x0700;
8010075a:	8b 15 00 90 10 80    	mov    0x80109000,%edx
80100760:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100763:	01 c0                	add    %eax,%eax
80100765:	01 d0                	add    %edx,%eax
80100767:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
8010076c:	c9                   	leave  
8010076d:	c3                   	ret    

8010076e <consputc>:

void
consputc(int c)
{
8010076e:	55                   	push   %ebp
8010076f:	89 e5                	mov    %esp,%ebp
80100771:	83 ec 18             	sub    $0x18,%esp
  if(panicked){
80100774:	a1 c0 b5 10 80       	mov    0x8010b5c0,%eax
80100779:	85 c0                	test   %eax,%eax
8010077b:	74 07                	je     80100784 <consputc+0x16>
    cli();
8010077d:	e8 8d fb ff ff       	call   8010030f <cli>
    for(;;)
      ;
80100782:	eb fe                	jmp    80100782 <consputc+0x14>
  }

  if(c == BACKSPACE){
80100784:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010078b:	75 26                	jne    801007b3 <consputc+0x45>
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010078d:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100794:	e8 37 64 00 00       	call   80106bd0 <uartputc>
80100799:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801007a0:	e8 2b 64 00 00       	call   80106bd0 <uartputc>
801007a5:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801007ac:	e8 1f 64 00 00       	call   80106bd0 <uartputc>
801007b1:	eb 0b                	jmp    801007be <consputc+0x50>
  } else
    uartputc(c);
801007b3:	8b 45 08             	mov    0x8(%ebp),%eax
801007b6:	89 04 24             	mov    %eax,(%esp)
801007b9:	e8 12 64 00 00       	call   80106bd0 <uartputc>
  cgaputc(c);
801007be:	8b 45 08             	mov    0x8(%ebp),%eax
801007c1:	89 04 24             	mov    %eax,(%esp)
801007c4:	e8 19 fe ff ff       	call   801005e2 <cgaputc>
}
801007c9:	c9                   	leave  
801007ca:	c3                   	ret    

801007cb <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007cb:	55                   	push   %ebp
801007cc:	89 e5                	mov    %esp,%ebp
801007ce:	83 ec 28             	sub    $0x28,%esp
  int c, doprocdump = 0;
801007d1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
801007d8:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
801007df:	e8 43 47 00 00       	call   80104f27 <acquire>
  while((c = getc()) >= 0){
801007e4:	e9 2f 01 00 00       	jmp    80100918 <consoleintr+0x14d>
    switch(c){
801007e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801007ec:	83 f8 10             	cmp    $0x10,%eax
801007ef:	74 1b                	je     8010080c <consoleintr+0x41>
801007f1:	83 f8 10             	cmp    $0x10,%eax
801007f4:	7f 0a                	jg     80100800 <consoleintr+0x35>
801007f6:	83 f8 08             	cmp    $0x8,%eax
801007f9:	74 5e                	je     80100859 <consoleintr+0x8e>
801007fb:	e9 89 00 00 00       	jmp    80100889 <consoleintr+0xbe>
80100800:	83 f8 15             	cmp    $0x15,%eax
80100803:	74 2c                	je     80100831 <consoleintr+0x66>
80100805:	83 f8 7f             	cmp    $0x7f,%eax
80100808:	74 4f                	je     80100859 <consoleintr+0x8e>
8010080a:	eb 7d                	jmp    80100889 <consoleintr+0xbe>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
8010080c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100813:	e9 00 01 00 00       	jmp    80100918 <consoleintr+0x14d>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100818:	a1 68 10 11 80       	mov    0x80111068,%eax
8010081d:	48                   	dec    %eax
8010081e:	a3 68 10 11 80       	mov    %eax,0x80111068
        consputc(BACKSPACE);
80100823:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
8010082a:	e8 3f ff ff ff       	call   8010076e <consputc>
8010082f:	eb 01                	jmp    80100832 <consoleintr+0x67>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100831:	90                   	nop
80100832:	8b 15 68 10 11 80    	mov    0x80111068,%edx
80100838:	a1 64 10 11 80       	mov    0x80111064,%eax
8010083d:	39 c2                	cmp    %eax,%edx
8010083f:	74 13                	je     80100854 <consoleintr+0x89>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100841:	a1 68 10 11 80       	mov    0x80111068,%eax
80100846:	48                   	dec    %eax
80100847:	83 e0 7f             	and    $0x7f,%eax
8010084a:	8a 80 e0 0f 11 80    	mov    -0x7feef020(%eax),%al
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100850:	3c 0a                	cmp    $0xa,%al
80100852:	75 c4                	jne    80100818 <consoleintr+0x4d>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100854:	e9 bf 00 00 00       	jmp    80100918 <consoleintr+0x14d>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100859:	8b 15 68 10 11 80    	mov    0x80111068,%edx
8010085f:	a1 64 10 11 80       	mov    0x80111064,%eax
80100864:	39 c2                	cmp    %eax,%edx
80100866:	74 1c                	je     80100884 <consoleintr+0xb9>
        input.e--;
80100868:	a1 68 10 11 80       	mov    0x80111068,%eax
8010086d:	48                   	dec    %eax
8010086e:	a3 68 10 11 80       	mov    %eax,0x80111068
        consputc(BACKSPACE);
80100873:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
8010087a:	e8 ef fe ff ff       	call   8010076e <consputc>
      }
      break;
8010087f:	e9 94 00 00 00       	jmp    80100918 <consoleintr+0x14d>
80100884:	e9 8f 00 00 00       	jmp    80100918 <consoleintr+0x14d>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100889:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010088d:	0f 84 84 00 00 00    	je     80100917 <consoleintr+0x14c>
80100893:	8b 15 68 10 11 80    	mov    0x80111068,%edx
80100899:	a1 60 10 11 80       	mov    0x80111060,%eax
8010089e:	29 c2                	sub    %eax,%edx
801008a0:	89 d0                	mov    %edx,%eax
801008a2:	83 f8 7f             	cmp    $0x7f,%eax
801008a5:	77 70                	ja     80100917 <consoleintr+0x14c>
        c = (c == '\r') ? '\n' : c;
801008a7:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801008ab:	74 05                	je     801008b2 <consoleintr+0xe7>
801008ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008b0:	eb 05                	jmp    801008b7 <consoleintr+0xec>
801008b2:	b8 0a 00 00 00       	mov    $0xa,%eax
801008b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008ba:	a1 68 10 11 80       	mov    0x80111068,%eax
801008bf:	8d 50 01             	lea    0x1(%eax),%edx
801008c2:	89 15 68 10 11 80    	mov    %edx,0x80111068
801008c8:	83 e0 7f             	and    $0x7f,%eax
801008cb:	89 c2                	mov    %eax,%edx
801008cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008d0:	88 82 e0 0f 11 80    	mov    %al,-0x7feef020(%edx)
        consputc(c);
801008d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008d9:	89 04 24             	mov    %eax,(%esp)
801008dc:	e8 8d fe ff ff       	call   8010076e <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801008e1:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
801008e5:	74 18                	je     801008ff <consoleintr+0x134>
801008e7:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
801008eb:	74 12                	je     801008ff <consoleintr+0x134>
801008ed:	a1 68 10 11 80       	mov    0x80111068,%eax
801008f2:	8b 15 60 10 11 80    	mov    0x80111060,%edx
801008f8:	83 ea 80             	sub    $0xffffff80,%edx
801008fb:	39 d0                	cmp    %edx,%eax
801008fd:	75 18                	jne    80100917 <consoleintr+0x14c>
          input.w = input.e;
801008ff:	a1 68 10 11 80       	mov    0x80111068,%eax
80100904:	a3 64 10 11 80       	mov    %eax,0x80111064
          wakeup(&input.r);
80100909:	c7 04 24 60 10 11 80 	movl   $0x80111060,(%esp)
80100910:	e8 1a 43 00 00       	call   80104c2f <wakeup>
        }
      }
      break;
80100915:	eb 00                	jmp    80100917 <consoleintr+0x14c>
80100917:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c, doprocdump = 0;

  acquire(&cons.lock);
  while((c = getc()) >= 0){
80100918:	8b 45 08             	mov    0x8(%ebp),%eax
8010091b:	ff d0                	call   *%eax
8010091d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100920:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100924:	0f 89 bf fe ff ff    	jns    801007e9 <consoleintr+0x1e>
        }
      }
      break;
    }
  }
  release(&cons.lock);
8010092a:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100931:	e8 58 46 00 00       	call   80104f8e <release>
  if(doprocdump) {
80100936:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010093a:	74 05                	je     80100941 <consoleintr+0x176>
    procdump();  // now call procdump() wo. cons.lock held
8010093c:	e8 91 43 00 00       	call   80104cd2 <procdump>
  }
}
80100941:	c9                   	leave  
80100942:	c3                   	ret    

80100943 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100943:	55                   	push   %ebp
80100944:	89 e5                	mov    %esp,%ebp
80100946:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;

  iunlock(ip);
80100949:	8b 45 08             	mov    0x8(%ebp),%eax
8010094c:	89 04 24             	mov    %eax,(%esp)
8010094f:	e8 de 10 00 00       	call   80101a32 <iunlock>
  target = n;
80100954:	8b 45 10             	mov    0x10(%ebp),%eax
80100957:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
8010095a:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100961:	e8 c1 45 00 00       	call   80104f27 <acquire>
  while(n > 0){
80100966:	e9 a6 00 00 00       	jmp    80100a11 <consoleread+0xce>
    while(input.r == input.w){
8010096b:	eb 42                	jmp    801009af <consoleread+0x6c>
      if(proc->killed){
8010096d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100973:	8b 40 24             	mov    0x24(%eax),%eax
80100976:	85 c0                	test   %eax,%eax
80100978:	74 21                	je     8010099b <consoleread+0x58>
        release(&cons.lock);
8010097a:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100981:	e8 08 46 00 00       	call   80104f8e <release>
        ilock(ip);
80100986:	8b 45 08             	mov    0x8(%ebp),%eax
80100989:	89 04 24             	mov    %eax,(%esp)
8010098c:	e8 8d 0f 00 00       	call   8010191e <ilock>
        return -1;
80100991:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100996:	e9 a1 00 00 00       	jmp    80100a3c <consoleread+0xf9>
      }
      sleep(&input.r, &cons.lock);
8010099b:	c7 44 24 04 e0 b5 10 	movl   $0x8010b5e0,0x4(%esp)
801009a2:	80 
801009a3:	c7 04 24 60 10 11 80 	movl   $0x80111060,(%esp)
801009aa:	e8 a7 41 00 00       	call   80104b56 <sleep>

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while(input.r == input.w){
801009af:	8b 15 60 10 11 80    	mov    0x80111060,%edx
801009b5:	a1 64 10 11 80       	mov    0x80111064,%eax
801009ba:	39 c2                	cmp    %eax,%edx
801009bc:	74 af                	je     8010096d <consoleread+0x2a>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
801009be:	a1 60 10 11 80       	mov    0x80111060,%eax
801009c3:	8d 50 01             	lea    0x1(%eax),%edx
801009c6:	89 15 60 10 11 80    	mov    %edx,0x80111060
801009cc:	83 e0 7f             	and    $0x7f,%eax
801009cf:	8a 80 e0 0f 11 80    	mov    -0x7feef020(%eax),%al
801009d5:	0f be c0             	movsbl %al,%eax
801009d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
801009db:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
801009df:	75 17                	jne    801009f8 <consoleread+0xb5>
      if(n < target){
801009e1:	8b 45 10             	mov    0x10(%ebp),%eax
801009e4:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801009e7:	73 0d                	jae    801009f6 <consoleread+0xb3>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
801009e9:	a1 60 10 11 80       	mov    0x80111060,%eax
801009ee:	48                   	dec    %eax
801009ef:	a3 60 10 11 80       	mov    %eax,0x80111060
      }
      break;
801009f4:	eb 25                	jmp    80100a1b <consoleread+0xd8>
801009f6:	eb 23                	jmp    80100a1b <consoleread+0xd8>
    }
    *dst++ = c;
801009f8:	8b 45 0c             	mov    0xc(%ebp),%eax
801009fb:	8d 50 01             	lea    0x1(%eax),%edx
801009fe:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a01:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a04:	88 10                	mov    %dl,(%eax)
    --n;
80100a06:	ff 4d 10             	decl   0x10(%ebp)
    if(c == '\n')
80100a09:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a0d:	75 02                	jne    80100a11 <consoleread+0xce>
      break;
80100a0f:	eb 0a                	jmp    80100a1b <consoleread+0xd8>
  int c;

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
80100a11:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a15:	0f 8f 50 ff ff ff    	jg     8010096b <consoleread+0x28>
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
  }
  release(&cons.lock);
80100a1b:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100a22:	e8 67 45 00 00       	call   80104f8e <release>
  ilock(ip);
80100a27:	8b 45 08             	mov    0x8(%ebp),%eax
80100a2a:	89 04 24             	mov    %eax,(%esp)
80100a2d:	e8 ec 0e 00 00       	call   8010191e <ilock>

  return target - n;
80100a32:	8b 45 10             	mov    0x10(%ebp),%eax
80100a35:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a38:	29 c2                	sub    %eax,%edx
80100a3a:	89 d0                	mov    %edx,%eax
}
80100a3c:	c9                   	leave  
80100a3d:	c3                   	ret    

80100a3e <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a3e:	55                   	push   %ebp
80100a3f:	89 e5                	mov    %esp,%ebp
80100a41:	83 ec 28             	sub    $0x28,%esp
  int i;

  iunlock(ip);
80100a44:	8b 45 08             	mov    0x8(%ebp),%eax
80100a47:	89 04 24             	mov    %eax,(%esp)
80100a4a:	e8 e3 0f 00 00       	call   80101a32 <iunlock>
  acquire(&cons.lock);
80100a4f:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100a56:	e8 cc 44 00 00       	call   80104f27 <acquire>
  for(i = 0; i < n; i++)
80100a5b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100a62:	eb 1b                	jmp    80100a7f <consolewrite+0x41>
    consputc(buf[i] & 0xff);
80100a64:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a67:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a6a:	01 d0                	add    %edx,%eax
80100a6c:	8a 00                	mov    (%eax),%al
80100a6e:	0f be c0             	movsbl %al,%eax
80100a71:	0f b6 c0             	movzbl %al,%eax
80100a74:	89 04 24             	mov    %eax,(%esp)
80100a77:	e8 f2 fc ff ff       	call   8010076e <consputc>
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100a7c:	ff 45 f4             	incl   -0xc(%ebp)
80100a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a82:	3b 45 10             	cmp    0x10(%ebp),%eax
80100a85:	7c dd                	jl     80100a64 <consolewrite+0x26>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100a87:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100a8e:	e8 fb 44 00 00       	call   80104f8e <release>
  ilock(ip);
80100a93:	8b 45 08             	mov    0x8(%ebp),%eax
80100a96:	89 04 24             	mov    %eax,(%esp)
80100a99:	e8 80 0e 00 00       	call   8010191e <ilock>

  return n;
80100a9e:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100aa1:	c9                   	leave  
80100aa2:	c3                   	ret    

80100aa3 <consoleinit>:

void
consoleinit(void)
{
80100aa3:	55                   	push   %ebp
80100aa4:	89 e5                	mov    %esp,%ebp
80100aa6:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100aa9:	c7 44 24 04 b2 85 10 	movl   $0x801085b2,0x4(%esp)
80100ab0:	80 
80100ab1:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100ab8:	e8 49 44 00 00       	call   80104f06 <initlock>

  devsw[CONSOLE].write = consolewrite;
80100abd:	c7 05 2c 1a 11 80 3e 	movl   $0x80100a3e,0x80111a2c
80100ac4:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100ac7:	c7 05 28 1a 11 80 43 	movl   $0x80100943,0x80111a28
80100ace:	09 10 80 
  cons.locking = 1;
80100ad1:	c7 05 14 b6 10 80 01 	movl   $0x1,0x8010b614
80100ad8:	00 00 00 

  picenable(IRQ_KBD);
80100adb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100ae2:	e8 9d 32 00 00       	call   80103d84 <picenable>
  ioapicenable(IRQ_KBD, 0);
80100ae7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100aee:	00 
80100aef:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100af6:	e8 f2 1e 00 00       	call   801029ed <ioapicenable>
}
80100afb:	c9                   	leave  
80100afc:	c3                   	ret    
80100afd:	00 00                	add    %al,(%eax)
	...

80100b00 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b00:	55                   	push   %ebp
80100b01:	89 e5                	mov    %esp,%ebp
80100b03:	81 ec 38 01 00 00    	sub    $0x138,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100b09:	e8 b5 29 00 00       	call   801034c3 <begin_op>

  if((ip = namei(path)) == 0){
80100b0e:	8b 45 08             	mov    0x8(%ebp),%eax
80100b11:	89 04 24             	mov    %eax,(%esp)
80100b14:	e8 18 19 00 00       	call   80102431 <namei>
80100b19:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b1c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b20:	75 0f                	jne    80100b31 <exec+0x31>
    end_op();
80100b22:	e8 1e 2a 00 00       	call   80103545 <end_op>
    return -1;
80100b27:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100b2c:	e9 0b 04 00 00       	jmp    80100f3c <exec+0x43c>
  }
  ilock(ip);
80100b31:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b34:	89 04 24             	mov    %eax,(%esp)
80100b37:	e8 e2 0d 00 00       	call   8010191e <ilock>
  pgdir = 0;
80100b3c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100b43:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100b4a:	00 
80100b4b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100b52:	00 
80100b53:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100b59:	89 44 24 04          	mov    %eax,0x4(%esp)
80100b5d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b60:	89 04 24             	mov    %eax,(%esp)
80100b63:	e8 3a 12 00 00       	call   80101da2 <readi>
80100b68:	83 f8 33             	cmp    $0x33,%eax
80100b6b:	77 05                	ja     80100b72 <exec+0x72>
    goto bad;
80100b6d:	e9 9e 03 00 00       	jmp    80100f10 <exec+0x410>
  if(elf.magic != ELF_MAGIC)
80100b72:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100b78:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100b7d:	74 05                	je     80100b84 <exec+0x84>
    goto bad;
80100b7f:	e9 8c 03 00 00       	jmp    80100f10 <exec+0x410>

  if((pgdir = setupkvm()) == 0)
80100b84:	e8 57 71 00 00       	call   80107ce0 <setupkvm>
80100b89:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100b8c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100b90:	75 05                	jne    80100b97 <exec+0x97>
    goto bad;
80100b92:	e9 79 03 00 00       	jmp    80100f10 <exec+0x410>

  // Load program into memory.
  sz = 0;
80100b97:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100b9e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100ba5:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100bab:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100bae:	e9 fb 00 00 00       	jmp    80100cae <exec+0x1ae>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100bb3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100bb6:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100bbd:	00 
80100bbe:	89 44 24 08          	mov    %eax,0x8(%esp)
80100bc2:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100bc8:	89 44 24 04          	mov    %eax,0x4(%esp)
80100bcc:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100bcf:	89 04 24             	mov    %eax,(%esp)
80100bd2:	e8 cb 11 00 00       	call   80101da2 <readi>
80100bd7:	83 f8 20             	cmp    $0x20,%eax
80100bda:	74 05                	je     80100be1 <exec+0xe1>
      goto bad;
80100bdc:	e9 2f 03 00 00       	jmp    80100f10 <exec+0x410>
    if(ph.type != ELF_PROG_LOAD)
80100be1:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100be7:	83 f8 01             	cmp    $0x1,%eax
80100bea:	74 05                	je     80100bf1 <exec+0xf1>
      continue;
80100bec:	e9 b1 00 00 00       	jmp    80100ca2 <exec+0x1a2>
    if(ph.memsz < ph.filesz)
80100bf1:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100bf7:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100bfd:	39 c2                	cmp    %eax,%edx
80100bff:	73 05                	jae    80100c06 <exec+0x106>
      goto bad;
80100c01:	e9 0a 03 00 00       	jmp    80100f10 <exec+0x410>
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100c06:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100c0c:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100c12:	01 c2                	add    %eax,%edx
80100c14:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100c1a:	39 c2                	cmp    %eax,%edx
80100c1c:	73 05                	jae    80100c23 <exec+0x123>
      goto bad;
80100c1e:	e9 ed 02 00 00       	jmp    80100f10 <exec+0x410>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c23:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100c29:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100c2f:	01 d0                	add    %edx,%eax
80100c31:	89 44 24 08          	mov    %eax,0x8(%esp)
80100c35:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c38:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c3c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c3f:	89 04 24             	mov    %eax,(%esp)
80100c42:	e8 34 74 00 00       	call   8010807b <allocuvm>
80100c47:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c4a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c4e:	75 05                	jne    80100c55 <exec+0x155>
      goto bad;
80100c50:	e9 bb 02 00 00       	jmp    80100f10 <exec+0x410>
    if(ph.vaddr % PGSIZE != 0)
80100c55:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100c5b:	25 ff 0f 00 00       	and    $0xfff,%eax
80100c60:	85 c0                	test   %eax,%eax
80100c62:	74 05                	je     80100c69 <exec+0x169>
      goto bad;
80100c64:	e9 a7 02 00 00       	jmp    80100f10 <exec+0x410>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100c69:	8b 8d fc fe ff ff    	mov    -0x104(%ebp),%ecx
80100c6f:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c75:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100c7b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100c7f:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100c83:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100c86:	89 54 24 08          	mov    %edx,0x8(%esp)
80100c8a:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c8e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c91:	89 04 24             	mov    %eax,(%esp)
80100c94:	e8 ff 72 00 00       	call   80107f98 <loaduvm>
80100c99:	85 c0                	test   %eax,%eax
80100c9b:	79 05                	jns    80100ca2 <exec+0x1a2>
      goto bad;
80100c9d:	e9 6e 02 00 00       	jmp    80100f10 <exec+0x410>
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100ca2:	ff 45 ec             	incl   -0x14(%ebp)
80100ca5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100ca8:	83 c0 20             	add    $0x20,%eax
80100cab:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100cae:	8b 85 38 ff ff ff    	mov    -0xc8(%ebp),%eax
80100cb4:	0f b7 c0             	movzwl %ax,%eax
80100cb7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100cba:	0f 8f f3 fe ff ff    	jg     80100bb3 <exec+0xb3>
    if(ph.vaddr % PGSIZE != 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100cc0:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100cc3:	89 04 24             	mov    %eax,(%esp)
80100cc6:	e8 3f 0e 00 00       	call   80101b0a <iunlockput>
  end_op();
80100ccb:	e8 75 28 00 00       	call   80103545 <end_op>
  ip = 0;
80100cd0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100cd7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cda:	05 ff 0f 00 00       	add    $0xfff,%eax
80100cdf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100ce4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100ce7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cea:	05 00 20 00 00       	add    $0x2000,%eax
80100cef:	89 44 24 08          	mov    %eax,0x8(%esp)
80100cf3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cf6:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cfa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100cfd:	89 04 24             	mov    %eax,(%esp)
80100d00:	e8 76 73 00 00       	call   8010807b <allocuvm>
80100d05:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d08:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d0c:	75 05                	jne    80100d13 <exec+0x213>
    goto bad;
80100d0e:	e9 fd 01 00 00       	jmp    80100f10 <exec+0x410>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d13:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d16:	2d 00 20 00 00       	sub    $0x2000,%eax
80100d1b:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d1f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100d22:	89 04 24             	mov    %eax,(%esp)
80100d25:	e8 b3 75 00 00       	call   801082dd <clearpteu>
  sp = sz;
80100d2a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d2d:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d30:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d37:	e9 95 00 00 00       	jmp    80100dd1 <exec+0x2d1>
    if(argc >= MAXARG)
80100d3c:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d40:	76 05                	jbe    80100d47 <exec+0x247>
      goto bad;
80100d42:	e9 c9 01 00 00       	jmp    80100f10 <exec+0x410>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d4a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d51:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d54:	01 d0                	add    %edx,%eax
80100d56:	8b 00                	mov    (%eax),%eax
80100d58:	89 04 24             	mov    %eax,(%esp)
80100d5b:	e8 7d 46 00 00       	call   801053dd <strlen>
80100d60:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100d63:	29 c2                	sub    %eax,%edx
80100d65:	89 d0                	mov    %edx,%eax
80100d67:	48                   	dec    %eax
80100d68:	83 e0 fc             	and    $0xfffffffc,%eax
80100d6b:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d6e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d71:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d78:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d7b:	01 d0                	add    %edx,%eax
80100d7d:	8b 00                	mov    (%eax),%eax
80100d7f:	89 04 24             	mov    %eax,(%esp)
80100d82:	e8 56 46 00 00       	call   801053dd <strlen>
80100d87:	40                   	inc    %eax
80100d88:	89 c2                	mov    %eax,%edx
80100d8a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d8d:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100d94:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d97:	01 c8                	add    %ecx,%eax
80100d99:	8b 00                	mov    (%eax),%eax
80100d9b:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100d9f:	89 44 24 08          	mov    %eax,0x8(%esp)
80100da3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100da6:	89 44 24 04          	mov    %eax,0x4(%esp)
80100daa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100dad:	89 04 24             	mov    %eax,(%esp)
80100db0:	e8 e0 76 00 00       	call   80108495 <copyout>
80100db5:	85 c0                	test   %eax,%eax
80100db7:	79 05                	jns    80100dbe <exec+0x2be>
      goto bad;
80100db9:	e9 52 01 00 00       	jmp    80100f10 <exec+0x410>
    ustack[3+argc] = sp;
80100dbe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dc1:	8d 50 03             	lea    0x3(%eax),%edx
80100dc4:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dc7:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100dce:	ff 45 e4             	incl   -0x1c(%ebp)
80100dd1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dd4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ddb:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dde:	01 d0                	add    %edx,%eax
80100de0:	8b 00                	mov    (%eax),%eax
80100de2:	85 c0                	test   %eax,%eax
80100de4:	0f 85 52 ff ff ff    	jne    80100d3c <exec+0x23c>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100dea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ded:	83 c0 03             	add    $0x3,%eax
80100df0:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100df7:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100dfb:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100e02:	ff ff ff 
  ustack[1] = argc;
80100e05:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e08:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e0e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e11:	40                   	inc    %eax
80100e12:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e19:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e1c:	29 d0                	sub    %edx,%eax
80100e1e:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100e24:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e27:	83 c0 04             	add    $0x4,%eax
80100e2a:	c1 e0 02             	shl    $0x2,%eax
80100e2d:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e30:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e33:	83 c0 04             	add    $0x4,%eax
80100e36:	c1 e0 02             	shl    $0x2,%eax
80100e39:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100e3d:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100e43:	89 44 24 08          	mov    %eax,0x8(%esp)
80100e47:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e4a:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e4e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100e51:	89 04 24             	mov    %eax,(%esp)
80100e54:	e8 3c 76 00 00       	call   80108495 <copyout>
80100e59:	85 c0                	test   %eax,%eax
80100e5b:	79 05                	jns    80100e62 <exec+0x362>
    goto bad;
80100e5d:	e9 ae 00 00 00       	jmp    80100f10 <exec+0x410>

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e62:	8b 45 08             	mov    0x8(%ebp),%eax
80100e65:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100e68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e6b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100e6e:	eb 13                	jmp    80100e83 <exec+0x383>
    if(*s == '/')
80100e70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e73:	8a 00                	mov    (%eax),%al
80100e75:	3c 2f                	cmp    $0x2f,%al
80100e77:	75 07                	jne    80100e80 <exec+0x380>
      last = s+1;
80100e79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e7c:	40                   	inc    %eax
80100e7d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e80:	ff 45 f4             	incl   -0xc(%ebp)
80100e83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e86:	8a 00                	mov    (%eax),%al
80100e88:	84 c0                	test   %al,%al
80100e8a:	75 e4                	jne    80100e70 <exec+0x370>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100e8c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e92:	8d 50 6c             	lea    0x6c(%eax),%edx
80100e95:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80100e9c:	00 
80100e9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100ea0:	89 44 24 04          	mov    %eax,0x4(%esp)
80100ea4:	89 14 24             	mov    %edx,(%esp)
80100ea7:	e8 ea 44 00 00       	call   80105396 <safestrcpy>

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100eac:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eb2:	8b 40 04             	mov    0x4(%eax),%eax
80100eb5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100eb8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ebe:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100ec1:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100ec4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eca:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100ecd:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100ecf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ed5:	8b 40 18             	mov    0x18(%eax),%eax
80100ed8:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100ede:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100ee1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ee7:	8b 40 18             	mov    0x18(%eax),%eax
80100eea:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100eed:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100ef0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ef6:	89 04 24             	mov    %eax,(%esp)
80100ef9:	e8 ae 6e 00 00       	call   80107dac <switchuvm>
  freevm(oldpgdir);
80100efe:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f01:	89 04 24             	mov    %eax,(%esp)
80100f04:	e8 3e 73 00 00       	call   80108247 <freevm>
  return 0;
80100f09:	b8 00 00 00 00       	mov    $0x0,%eax
80100f0e:	eb 2c                	jmp    80100f3c <exec+0x43c>

 bad:
  if(pgdir)
80100f10:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f14:	74 0b                	je     80100f21 <exec+0x421>
    freevm(pgdir);
80100f16:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100f19:	89 04 24             	mov    %eax,(%esp)
80100f1c:	e8 26 73 00 00       	call   80108247 <freevm>
  if(ip){
80100f21:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f25:	74 10                	je     80100f37 <exec+0x437>
    iunlockput(ip);
80100f27:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100f2a:	89 04 24             	mov    %eax,(%esp)
80100f2d:	e8 d8 0b 00 00       	call   80101b0a <iunlockput>
    end_op();
80100f32:	e8 0e 26 00 00       	call   80103545 <end_op>
  }
  return -1;
80100f37:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100f3c:	c9                   	leave  
80100f3d:	c3                   	ret    
	...

80100f40 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100f40:	55                   	push   %ebp
80100f41:	89 e5                	mov    %esp,%ebp
80100f43:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
80100f46:	c7 44 24 04 ba 85 10 	movl   $0x801085ba,0x4(%esp)
80100f4d:	80 
80100f4e:	c7 04 24 80 10 11 80 	movl   $0x80111080,(%esp)
80100f55:	e8 ac 3f 00 00       	call   80104f06 <initlock>
}
80100f5a:	c9                   	leave  
80100f5b:	c3                   	ret    

80100f5c <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f5c:	55                   	push   %ebp
80100f5d:	89 e5                	mov    %esp,%ebp
80100f5f:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
80100f62:	c7 04 24 80 10 11 80 	movl   $0x80111080,(%esp)
80100f69:	e8 b9 3f 00 00       	call   80104f27 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f6e:	c7 45 f4 b4 10 11 80 	movl   $0x801110b4,-0xc(%ebp)
80100f75:	eb 29                	jmp    80100fa0 <filealloc+0x44>
    if(f->ref == 0){
80100f77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f7a:	8b 40 04             	mov    0x4(%eax),%eax
80100f7d:	85 c0                	test   %eax,%eax
80100f7f:	75 1b                	jne    80100f9c <filealloc+0x40>
      f->ref = 1;
80100f81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f84:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100f8b:	c7 04 24 80 10 11 80 	movl   $0x80111080,(%esp)
80100f92:	e8 f7 3f 00 00       	call   80104f8e <release>
      return f;
80100f97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f9a:	eb 1e                	jmp    80100fba <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f9c:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100fa0:	81 7d f4 14 1a 11 80 	cmpl   $0x80111a14,-0xc(%ebp)
80100fa7:	72 ce                	jb     80100f77 <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100fa9:	c7 04 24 80 10 11 80 	movl   $0x80111080,(%esp)
80100fb0:	e8 d9 3f 00 00       	call   80104f8e <release>
  return 0;
80100fb5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100fba:	c9                   	leave  
80100fbb:	c3                   	ret    

80100fbc <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100fbc:	55                   	push   %ebp
80100fbd:	89 e5                	mov    %esp,%ebp
80100fbf:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
80100fc2:	c7 04 24 80 10 11 80 	movl   $0x80111080,(%esp)
80100fc9:	e8 59 3f 00 00       	call   80104f27 <acquire>
  if(f->ref < 1)
80100fce:	8b 45 08             	mov    0x8(%ebp),%eax
80100fd1:	8b 40 04             	mov    0x4(%eax),%eax
80100fd4:	85 c0                	test   %eax,%eax
80100fd6:	7f 0c                	jg     80100fe4 <filedup+0x28>
    panic("filedup");
80100fd8:	c7 04 24 c1 85 10 80 	movl   $0x801085c1,(%esp)
80100fdf:	e8 70 f5 ff ff       	call   80100554 <panic>
  f->ref++;
80100fe4:	8b 45 08             	mov    0x8(%ebp),%eax
80100fe7:	8b 40 04             	mov    0x4(%eax),%eax
80100fea:	8d 50 01             	lea    0x1(%eax),%edx
80100fed:	8b 45 08             	mov    0x8(%ebp),%eax
80100ff0:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80100ff3:	c7 04 24 80 10 11 80 	movl   $0x80111080,(%esp)
80100ffa:	e8 8f 3f 00 00       	call   80104f8e <release>
  return f;
80100fff:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101002:	c9                   	leave  
80101003:	c3                   	ret    

80101004 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101004:	55                   	push   %ebp
80101005:	89 e5                	mov    %esp,%ebp
80101007:	57                   	push   %edi
80101008:	56                   	push   %esi
80101009:	53                   	push   %ebx
8010100a:	83 ec 3c             	sub    $0x3c,%esp
  struct file ff;

  acquire(&ftable.lock);
8010100d:	c7 04 24 80 10 11 80 	movl   $0x80111080,(%esp)
80101014:	e8 0e 3f 00 00       	call   80104f27 <acquire>
  if(f->ref < 1)
80101019:	8b 45 08             	mov    0x8(%ebp),%eax
8010101c:	8b 40 04             	mov    0x4(%eax),%eax
8010101f:	85 c0                	test   %eax,%eax
80101021:	7f 0c                	jg     8010102f <fileclose+0x2b>
    panic("fileclose");
80101023:	c7 04 24 c9 85 10 80 	movl   $0x801085c9,(%esp)
8010102a:	e8 25 f5 ff ff       	call   80100554 <panic>
  if(--f->ref > 0){
8010102f:	8b 45 08             	mov    0x8(%ebp),%eax
80101032:	8b 40 04             	mov    0x4(%eax),%eax
80101035:	8d 50 ff             	lea    -0x1(%eax),%edx
80101038:	8b 45 08             	mov    0x8(%ebp),%eax
8010103b:	89 50 04             	mov    %edx,0x4(%eax)
8010103e:	8b 45 08             	mov    0x8(%ebp),%eax
80101041:	8b 40 04             	mov    0x4(%eax),%eax
80101044:	85 c0                	test   %eax,%eax
80101046:	7e 0e                	jle    80101056 <fileclose+0x52>
    release(&ftable.lock);
80101048:	c7 04 24 80 10 11 80 	movl   $0x80111080,(%esp)
8010104f:	e8 3a 3f 00 00       	call   80104f8e <release>
80101054:	eb 70                	jmp    801010c6 <fileclose+0xc2>
    return;
  }
  ff = *f;
80101056:	8b 45 08             	mov    0x8(%ebp),%eax
80101059:	8d 55 d0             	lea    -0x30(%ebp),%edx
8010105c:	89 c3                	mov    %eax,%ebx
8010105e:	b8 06 00 00 00       	mov    $0x6,%eax
80101063:	89 d7                	mov    %edx,%edi
80101065:	89 de                	mov    %ebx,%esi
80101067:	89 c1                	mov    %eax,%ecx
80101069:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  f->ref = 0;
8010106b:	8b 45 08             	mov    0x8(%ebp),%eax
8010106e:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101075:	8b 45 08             	mov    0x8(%ebp),%eax
80101078:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
8010107e:	c7 04 24 80 10 11 80 	movl   $0x80111080,(%esp)
80101085:	e8 04 3f 00 00       	call   80104f8e <release>

  if(ff.type == FD_PIPE)
8010108a:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010108d:	83 f8 01             	cmp    $0x1,%eax
80101090:	75 17                	jne    801010a9 <fileclose+0xa5>
    pipeclose(ff.pipe, ff.writable);
80101092:	8a 45 d9             	mov    -0x27(%ebp),%al
80101095:	0f be d0             	movsbl %al,%edx
80101098:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010109b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010109f:	89 04 24             	mov    %eax,(%esp)
801010a2:	e8 8c 2f 00 00       	call   80104033 <pipeclose>
801010a7:	eb 1d                	jmp    801010c6 <fileclose+0xc2>
  else if(ff.type == FD_INODE){
801010a9:	8b 45 d0             	mov    -0x30(%ebp),%eax
801010ac:	83 f8 02             	cmp    $0x2,%eax
801010af:	75 15                	jne    801010c6 <fileclose+0xc2>
    begin_op();
801010b1:	e8 0d 24 00 00       	call   801034c3 <begin_op>
    iput(ff.ip);
801010b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010b9:	89 04 24             	mov    %eax,(%esp)
801010bc:	e8 b5 09 00 00       	call   80101a76 <iput>
    end_op();
801010c1:	e8 7f 24 00 00       	call   80103545 <end_op>
  }
}
801010c6:	83 c4 3c             	add    $0x3c,%esp
801010c9:	5b                   	pop    %ebx
801010ca:	5e                   	pop    %esi
801010cb:	5f                   	pop    %edi
801010cc:	5d                   	pop    %ebp
801010cd:	c3                   	ret    

801010ce <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801010ce:	55                   	push   %ebp
801010cf:	89 e5                	mov    %esp,%ebp
801010d1:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
801010d4:	8b 45 08             	mov    0x8(%ebp),%eax
801010d7:	8b 00                	mov    (%eax),%eax
801010d9:	83 f8 02             	cmp    $0x2,%eax
801010dc:	75 38                	jne    80101116 <filestat+0x48>
    ilock(f->ip);
801010de:	8b 45 08             	mov    0x8(%ebp),%eax
801010e1:	8b 40 10             	mov    0x10(%eax),%eax
801010e4:	89 04 24             	mov    %eax,(%esp)
801010e7:	e8 32 08 00 00       	call   8010191e <ilock>
    stati(f->ip, st);
801010ec:	8b 45 08             	mov    0x8(%ebp),%eax
801010ef:	8b 40 10             	mov    0x10(%eax),%eax
801010f2:	8b 55 0c             	mov    0xc(%ebp),%edx
801010f5:	89 54 24 04          	mov    %edx,0x4(%esp)
801010f9:	89 04 24             	mov    %eax,(%esp)
801010fc:	e8 5d 0c 00 00       	call   80101d5e <stati>
    iunlock(f->ip);
80101101:	8b 45 08             	mov    0x8(%ebp),%eax
80101104:	8b 40 10             	mov    0x10(%eax),%eax
80101107:	89 04 24             	mov    %eax,(%esp)
8010110a:	e8 23 09 00 00       	call   80101a32 <iunlock>
    return 0;
8010110f:	b8 00 00 00 00       	mov    $0x0,%eax
80101114:	eb 05                	jmp    8010111b <filestat+0x4d>
  }
  return -1;
80101116:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010111b:	c9                   	leave  
8010111c:	c3                   	ret    

8010111d <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
8010111d:	55                   	push   %ebp
8010111e:	89 e5                	mov    %esp,%ebp
80101120:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
80101123:	8b 45 08             	mov    0x8(%ebp),%eax
80101126:	8a 40 08             	mov    0x8(%eax),%al
80101129:	84 c0                	test   %al,%al
8010112b:	75 0a                	jne    80101137 <fileread+0x1a>
    return -1;
8010112d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101132:	e9 9f 00 00 00       	jmp    801011d6 <fileread+0xb9>
  if(f->type == FD_PIPE)
80101137:	8b 45 08             	mov    0x8(%ebp),%eax
8010113a:	8b 00                	mov    (%eax),%eax
8010113c:	83 f8 01             	cmp    $0x1,%eax
8010113f:	75 1e                	jne    8010115f <fileread+0x42>
    return piperead(f->pipe, addr, n);
80101141:	8b 45 08             	mov    0x8(%ebp),%eax
80101144:	8b 40 0c             	mov    0xc(%eax),%eax
80101147:	8b 55 10             	mov    0x10(%ebp),%edx
8010114a:	89 54 24 08          	mov    %edx,0x8(%esp)
8010114e:	8b 55 0c             	mov    0xc(%ebp),%edx
80101151:	89 54 24 04          	mov    %edx,0x4(%esp)
80101155:	89 04 24             	mov    %eax,(%esp)
80101158:	e8 55 30 00 00       	call   801041b2 <piperead>
8010115d:	eb 77                	jmp    801011d6 <fileread+0xb9>
  if(f->type == FD_INODE){
8010115f:	8b 45 08             	mov    0x8(%ebp),%eax
80101162:	8b 00                	mov    (%eax),%eax
80101164:	83 f8 02             	cmp    $0x2,%eax
80101167:	75 61                	jne    801011ca <fileread+0xad>
    ilock(f->ip);
80101169:	8b 45 08             	mov    0x8(%ebp),%eax
8010116c:	8b 40 10             	mov    0x10(%eax),%eax
8010116f:	89 04 24             	mov    %eax,(%esp)
80101172:	e8 a7 07 00 00       	call   8010191e <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101177:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010117a:	8b 45 08             	mov    0x8(%ebp),%eax
8010117d:	8b 50 14             	mov    0x14(%eax),%edx
80101180:	8b 45 08             	mov    0x8(%ebp),%eax
80101183:	8b 40 10             	mov    0x10(%eax),%eax
80101186:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010118a:	89 54 24 08          	mov    %edx,0x8(%esp)
8010118e:	8b 55 0c             	mov    0xc(%ebp),%edx
80101191:	89 54 24 04          	mov    %edx,0x4(%esp)
80101195:	89 04 24             	mov    %eax,(%esp)
80101198:	e8 05 0c 00 00       	call   80101da2 <readi>
8010119d:	89 45 f4             	mov    %eax,-0xc(%ebp)
801011a0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801011a4:	7e 11                	jle    801011b7 <fileread+0x9a>
      f->off += r;
801011a6:	8b 45 08             	mov    0x8(%ebp),%eax
801011a9:	8b 50 14             	mov    0x14(%eax),%edx
801011ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011af:	01 c2                	add    %eax,%edx
801011b1:	8b 45 08             	mov    0x8(%ebp),%eax
801011b4:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801011b7:	8b 45 08             	mov    0x8(%ebp),%eax
801011ba:	8b 40 10             	mov    0x10(%eax),%eax
801011bd:	89 04 24             	mov    %eax,(%esp)
801011c0:	e8 6d 08 00 00       	call   80101a32 <iunlock>
    return r;
801011c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011c8:	eb 0c                	jmp    801011d6 <fileread+0xb9>
  }
  panic("fileread");
801011ca:	c7 04 24 d3 85 10 80 	movl   $0x801085d3,(%esp)
801011d1:	e8 7e f3 ff ff       	call   80100554 <panic>
}
801011d6:	c9                   	leave  
801011d7:	c3                   	ret    

801011d8 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801011d8:	55                   	push   %ebp
801011d9:	89 e5                	mov    %esp,%ebp
801011db:	53                   	push   %ebx
801011dc:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
801011df:	8b 45 08             	mov    0x8(%ebp),%eax
801011e2:	8a 40 09             	mov    0x9(%eax),%al
801011e5:	84 c0                	test   %al,%al
801011e7:	75 0a                	jne    801011f3 <filewrite+0x1b>
    return -1;
801011e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011ee:	e9 20 01 00 00       	jmp    80101313 <filewrite+0x13b>
  if(f->type == FD_PIPE)
801011f3:	8b 45 08             	mov    0x8(%ebp),%eax
801011f6:	8b 00                	mov    (%eax),%eax
801011f8:	83 f8 01             	cmp    $0x1,%eax
801011fb:	75 21                	jne    8010121e <filewrite+0x46>
    return pipewrite(f->pipe, addr, n);
801011fd:	8b 45 08             	mov    0x8(%ebp),%eax
80101200:	8b 40 0c             	mov    0xc(%eax),%eax
80101203:	8b 55 10             	mov    0x10(%ebp),%edx
80101206:	89 54 24 08          	mov    %edx,0x8(%esp)
8010120a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010120d:	89 54 24 04          	mov    %edx,0x4(%esp)
80101211:	89 04 24             	mov    %eax,(%esp)
80101214:	e8 ac 2e 00 00       	call   801040c5 <pipewrite>
80101219:	e9 f5 00 00 00       	jmp    80101313 <filewrite+0x13b>
  if(f->type == FD_INODE){
8010121e:	8b 45 08             	mov    0x8(%ebp),%eax
80101221:	8b 00                	mov    (%eax),%eax
80101223:	83 f8 02             	cmp    $0x2,%eax
80101226:	0f 85 db 00 00 00    	jne    80101307 <filewrite+0x12f>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
8010122c:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
80101233:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
8010123a:	e9 a8 00 00 00       	jmp    801012e7 <filewrite+0x10f>
      int n1 = n - i;
8010123f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101242:	8b 55 10             	mov    0x10(%ebp),%edx
80101245:	29 c2                	sub    %eax,%edx
80101247:	89 d0                	mov    %edx,%eax
80101249:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
8010124c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010124f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101252:	7e 06                	jle    8010125a <filewrite+0x82>
        n1 = max;
80101254:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101257:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
8010125a:	e8 64 22 00 00       	call   801034c3 <begin_op>
      ilock(f->ip);
8010125f:	8b 45 08             	mov    0x8(%ebp),%eax
80101262:	8b 40 10             	mov    0x10(%eax),%eax
80101265:	89 04 24             	mov    %eax,(%esp)
80101268:	e8 b1 06 00 00       	call   8010191e <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
8010126d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101270:	8b 45 08             	mov    0x8(%ebp),%eax
80101273:	8b 50 14             	mov    0x14(%eax),%edx
80101276:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101279:	8b 45 0c             	mov    0xc(%ebp),%eax
8010127c:	01 c3                	add    %eax,%ebx
8010127e:	8b 45 08             	mov    0x8(%ebp),%eax
80101281:	8b 40 10             	mov    0x10(%eax),%eax
80101284:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101288:	89 54 24 08          	mov    %edx,0x8(%esp)
8010128c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80101290:	89 04 24             	mov    %eax,(%esp)
80101293:	e8 6e 0c 00 00       	call   80101f06 <writei>
80101298:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010129b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010129f:	7e 11                	jle    801012b2 <filewrite+0xda>
        f->off += r;
801012a1:	8b 45 08             	mov    0x8(%ebp),%eax
801012a4:	8b 50 14             	mov    0x14(%eax),%edx
801012a7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012aa:	01 c2                	add    %eax,%edx
801012ac:	8b 45 08             	mov    0x8(%ebp),%eax
801012af:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801012b2:	8b 45 08             	mov    0x8(%ebp),%eax
801012b5:	8b 40 10             	mov    0x10(%eax),%eax
801012b8:	89 04 24             	mov    %eax,(%esp)
801012bb:	e8 72 07 00 00       	call   80101a32 <iunlock>
      end_op();
801012c0:	e8 80 22 00 00       	call   80103545 <end_op>

      if(r < 0)
801012c5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801012c9:	79 02                	jns    801012cd <filewrite+0xf5>
        break;
801012cb:	eb 26                	jmp    801012f3 <filewrite+0x11b>
      if(r != n1)
801012cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012d0:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801012d3:	74 0c                	je     801012e1 <filewrite+0x109>
        panic("short filewrite");
801012d5:	c7 04 24 dc 85 10 80 	movl   $0x801085dc,(%esp)
801012dc:	e8 73 f2 ff ff       	call   80100554 <panic>
      i += r;
801012e1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012e4:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
801012e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012ea:	3b 45 10             	cmp    0x10(%ebp),%eax
801012ed:	0f 8c 4c ff ff ff    	jl     8010123f <filewrite+0x67>
        break;
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
801012f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012f6:	3b 45 10             	cmp    0x10(%ebp),%eax
801012f9:	75 05                	jne    80101300 <filewrite+0x128>
801012fb:	8b 45 10             	mov    0x10(%ebp),%eax
801012fe:	eb 05                	jmp    80101305 <filewrite+0x12d>
80101300:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101305:	eb 0c                	jmp    80101313 <filewrite+0x13b>
  }
  panic("filewrite");
80101307:	c7 04 24 ec 85 10 80 	movl   $0x801085ec,(%esp)
8010130e:	e8 41 f2 ff ff       	call   80100554 <panic>
}
80101313:	83 c4 24             	add    $0x24,%esp
80101316:	5b                   	pop    %ebx
80101317:	5d                   	pop    %ebp
80101318:	c3                   	ret    
80101319:	00 00                	add    %al,(%eax)
	...

8010131c <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
8010131c:	55                   	push   %ebp
8010131d:	89 e5                	mov    %esp,%ebp
8010131f:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;

  bp = bread(dev, 1);
80101322:	8b 45 08             	mov    0x8(%ebp),%eax
80101325:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010132c:	00 
8010132d:	89 04 24             	mov    %eax,(%esp)
80101330:	e8 80 ee ff ff       	call   801001b5 <bread>
80101335:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101338:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010133b:	83 c0 5c             	add    $0x5c,%eax
8010133e:	c7 44 24 08 1c 00 00 	movl   $0x1c,0x8(%esp)
80101345:	00 
80101346:	89 44 24 04          	mov    %eax,0x4(%esp)
8010134a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010134d:	89 04 24             	mov    %eax,(%esp)
80101350:	e8 fe 3e 00 00       	call   80105253 <memmove>
  brelse(bp);
80101355:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101358:	89 04 24             	mov    %eax,(%esp)
8010135b:	e8 cc ee ff ff       	call   8010022c <brelse>
}
80101360:	c9                   	leave  
80101361:	c3                   	ret    

80101362 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101362:	55                   	push   %ebp
80101363:	89 e5                	mov    %esp,%ebp
80101365:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;

  bp = bread(dev, bno);
80101368:	8b 55 0c             	mov    0xc(%ebp),%edx
8010136b:	8b 45 08             	mov    0x8(%ebp),%eax
8010136e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101372:	89 04 24             	mov    %eax,(%esp)
80101375:	e8 3b ee ff ff       	call   801001b5 <bread>
8010137a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010137d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101380:	83 c0 5c             	add    $0x5c,%eax
80101383:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010138a:	00 
8010138b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101392:	00 
80101393:	89 04 24             	mov    %eax,(%esp)
80101396:	e8 ef 3d 00 00       	call   8010518a <memset>
  log_write(bp);
8010139b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010139e:	89 04 24             	mov    %eax,(%esp)
801013a1:	e8 21 23 00 00       	call   801036c7 <log_write>
  brelse(bp);
801013a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013a9:	89 04 24             	mov    %eax,(%esp)
801013ac:	e8 7b ee ff ff       	call   8010022c <brelse>
}
801013b1:	c9                   	leave  
801013b2:	c3                   	ret    

801013b3 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801013b3:	55                   	push   %ebp
801013b4:	89 e5                	mov    %esp,%ebp
801013b6:	83 ec 28             	sub    $0x28,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
801013b9:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
801013c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801013c7:	e9 03 01 00 00       	jmp    801014cf <balloc+0x11c>
    bp = bread(dev, BBLOCK(b, sb));
801013cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013cf:	85 c0                	test   %eax,%eax
801013d1:	79 05                	jns    801013d8 <balloc+0x25>
801013d3:	05 ff 0f 00 00       	add    $0xfff,%eax
801013d8:	c1 f8 0c             	sar    $0xc,%eax
801013db:	89 c2                	mov    %eax,%edx
801013dd:	a1 98 1a 11 80       	mov    0x80111a98,%eax
801013e2:	01 d0                	add    %edx,%eax
801013e4:	89 44 24 04          	mov    %eax,0x4(%esp)
801013e8:	8b 45 08             	mov    0x8(%ebp),%eax
801013eb:	89 04 24             	mov    %eax,(%esp)
801013ee:	e8 c2 ed ff ff       	call   801001b5 <bread>
801013f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801013f6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801013fd:	e9 9b 00 00 00       	jmp    8010149d <balloc+0xea>
      m = 1 << (bi % 8);
80101402:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101405:	25 07 00 00 80       	and    $0x80000007,%eax
8010140a:	85 c0                	test   %eax,%eax
8010140c:	79 05                	jns    80101413 <balloc+0x60>
8010140e:	48                   	dec    %eax
8010140f:	83 c8 f8             	or     $0xfffffff8,%eax
80101412:	40                   	inc    %eax
80101413:	ba 01 00 00 00       	mov    $0x1,%edx
80101418:	88 c1                	mov    %al,%cl
8010141a:	d3 e2                	shl    %cl,%edx
8010141c:	89 d0                	mov    %edx,%eax
8010141e:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101421:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101424:	85 c0                	test   %eax,%eax
80101426:	79 03                	jns    8010142b <balloc+0x78>
80101428:	83 c0 07             	add    $0x7,%eax
8010142b:	c1 f8 03             	sar    $0x3,%eax
8010142e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101431:	8a 44 02 5c          	mov    0x5c(%edx,%eax,1),%al
80101435:	0f b6 c0             	movzbl %al,%eax
80101438:	23 45 e8             	and    -0x18(%ebp),%eax
8010143b:	85 c0                	test   %eax,%eax
8010143d:	75 5b                	jne    8010149a <balloc+0xe7>
        bp->data[bi/8] |= m;  // Mark block in use.
8010143f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101442:	85 c0                	test   %eax,%eax
80101444:	79 03                	jns    80101449 <balloc+0x96>
80101446:	83 c0 07             	add    $0x7,%eax
80101449:	c1 f8 03             	sar    $0x3,%eax
8010144c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010144f:	8a 54 02 5c          	mov    0x5c(%edx,%eax,1),%dl
80101453:	88 d1                	mov    %dl,%cl
80101455:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101458:	09 ca                	or     %ecx,%edx
8010145a:	88 d1                	mov    %dl,%cl
8010145c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010145f:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
80101463:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101466:	89 04 24             	mov    %eax,(%esp)
80101469:	e8 59 22 00 00       	call   801036c7 <log_write>
        brelse(bp);
8010146e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101471:	89 04 24             	mov    %eax,(%esp)
80101474:	e8 b3 ed ff ff       	call   8010022c <brelse>
        bzero(dev, b + bi);
80101479:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010147c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010147f:	01 c2                	add    %eax,%edx
80101481:	8b 45 08             	mov    0x8(%ebp),%eax
80101484:	89 54 24 04          	mov    %edx,0x4(%esp)
80101488:	89 04 24             	mov    %eax,(%esp)
8010148b:	e8 d2 fe ff ff       	call   80101362 <bzero>
        return b + bi;
80101490:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101493:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101496:	01 d0                	add    %edx,%eax
80101498:	eb 51                	jmp    801014eb <balloc+0x138>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010149a:	ff 45 f0             	incl   -0x10(%ebp)
8010149d:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801014a4:	7f 17                	jg     801014bd <balloc+0x10a>
801014a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014ac:	01 d0                	add    %edx,%eax
801014ae:	89 c2                	mov    %eax,%edx
801014b0:	a1 80 1a 11 80       	mov    0x80111a80,%eax
801014b5:	39 c2                	cmp    %eax,%edx
801014b7:	0f 82 45 ff ff ff    	jb     80101402 <balloc+0x4f>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
801014bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014c0:	89 04 24             	mov    %eax,(%esp)
801014c3:	e8 64 ed ff ff       	call   8010022c <brelse>
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
801014c8:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801014cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014d2:	a1 80 1a 11 80       	mov    0x80111a80,%eax
801014d7:	39 c2                	cmp    %eax,%edx
801014d9:	0f 82 ed fe ff ff    	jb     801013cc <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
801014df:	c7 04 24 f8 85 10 80 	movl   $0x801085f8,(%esp)
801014e6:	e8 69 f0 ff ff       	call   80100554 <panic>
}
801014eb:	c9                   	leave  
801014ec:	c3                   	ret    

801014ed <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801014ed:	55                   	push   %ebp
801014ee:	89 e5                	mov    %esp,%ebp
801014f0:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
801014f3:	c7 44 24 04 80 1a 11 	movl   $0x80111a80,0x4(%esp)
801014fa:	80 
801014fb:	8b 45 08             	mov    0x8(%ebp),%eax
801014fe:	89 04 24             	mov    %eax,(%esp)
80101501:	e8 16 fe ff ff       	call   8010131c <readsb>
  bp = bread(dev, BBLOCK(b, sb));
80101506:	8b 45 0c             	mov    0xc(%ebp),%eax
80101509:	c1 e8 0c             	shr    $0xc,%eax
8010150c:	89 c2                	mov    %eax,%edx
8010150e:	a1 98 1a 11 80       	mov    0x80111a98,%eax
80101513:	01 c2                	add    %eax,%edx
80101515:	8b 45 08             	mov    0x8(%ebp),%eax
80101518:	89 54 24 04          	mov    %edx,0x4(%esp)
8010151c:	89 04 24             	mov    %eax,(%esp)
8010151f:	e8 91 ec ff ff       	call   801001b5 <bread>
80101524:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101527:	8b 45 0c             	mov    0xc(%ebp),%eax
8010152a:	25 ff 0f 00 00       	and    $0xfff,%eax
8010152f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
80101532:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101535:	25 07 00 00 80       	and    $0x80000007,%eax
8010153a:	85 c0                	test   %eax,%eax
8010153c:	79 05                	jns    80101543 <bfree+0x56>
8010153e:	48                   	dec    %eax
8010153f:	83 c8 f8             	or     $0xfffffff8,%eax
80101542:	40                   	inc    %eax
80101543:	ba 01 00 00 00       	mov    $0x1,%edx
80101548:	88 c1                	mov    %al,%cl
8010154a:	d3 e2                	shl    %cl,%edx
8010154c:	89 d0                	mov    %edx,%eax
8010154e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101551:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101554:	85 c0                	test   %eax,%eax
80101556:	79 03                	jns    8010155b <bfree+0x6e>
80101558:	83 c0 07             	add    $0x7,%eax
8010155b:	c1 f8 03             	sar    $0x3,%eax
8010155e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101561:	8a 44 02 5c          	mov    0x5c(%edx,%eax,1),%al
80101565:	0f b6 c0             	movzbl %al,%eax
80101568:	23 45 ec             	and    -0x14(%ebp),%eax
8010156b:	85 c0                	test   %eax,%eax
8010156d:	75 0c                	jne    8010157b <bfree+0x8e>
    panic("freeing free block");
8010156f:	c7 04 24 0e 86 10 80 	movl   $0x8010860e,(%esp)
80101576:	e8 d9 ef ff ff       	call   80100554 <panic>
  bp->data[bi/8] &= ~m;
8010157b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010157e:	85 c0                	test   %eax,%eax
80101580:	79 03                	jns    80101585 <bfree+0x98>
80101582:	83 c0 07             	add    $0x7,%eax
80101585:	c1 f8 03             	sar    $0x3,%eax
80101588:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010158b:	8a 54 02 5c          	mov    0x5c(%edx,%eax,1),%dl
8010158f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80101592:	f7 d1                	not    %ecx
80101594:	21 ca                	and    %ecx,%edx
80101596:	88 d1                	mov    %dl,%cl
80101598:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010159b:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
8010159f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015a2:	89 04 24             	mov    %eax,(%esp)
801015a5:	e8 1d 21 00 00       	call   801036c7 <log_write>
  brelse(bp);
801015aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015ad:	89 04 24             	mov    %eax,(%esp)
801015b0:	e8 77 ec ff ff       	call   8010022c <brelse>
}
801015b5:	c9                   	leave  
801015b6:	c3                   	ret    

801015b7 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
801015b7:	55                   	push   %ebp
801015b8:	89 e5                	mov    %esp,%ebp
801015ba:	57                   	push   %edi
801015bb:	56                   	push   %esi
801015bc:	53                   	push   %ebx
801015bd:	83 ec 4c             	sub    $0x4c,%esp
  int i = 0;
801015c0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
801015c7:	c7 44 24 04 21 86 10 	movl   $0x80108621,0x4(%esp)
801015ce:	80 
801015cf:	c7 04 24 a0 1a 11 80 	movl   $0x80111aa0,(%esp)
801015d6:	e8 2b 39 00 00       	call   80104f06 <initlock>
  for(i = 0; i < NINODE; i++) {
801015db:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801015e2:	eb 2b                	jmp    8010160f <iinit+0x58>
    initsleeplock(&icache.inode[i].lock, "inode");
801015e4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801015e7:	89 d0                	mov    %edx,%eax
801015e9:	c1 e0 03             	shl    $0x3,%eax
801015ec:	01 d0                	add    %edx,%eax
801015ee:	c1 e0 04             	shl    $0x4,%eax
801015f1:	83 c0 30             	add    $0x30,%eax
801015f4:	05 a0 1a 11 80       	add    $0x80111aa0,%eax
801015f9:	83 c0 10             	add    $0x10,%eax
801015fc:	c7 44 24 04 28 86 10 	movl   $0x80108628,0x4(%esp)
80101603:	80 
80101604:	89 04 24             	mov    %eax,(%esp)
80101607:	e8 bc 37 00 00       	call   80104dc8 <initsleeplock>
iinit(int dev)
{
  int i = 0;
  
  initlock(&icache.lock, "icache");
  for(i = 0; i < NINODE; i++) {
8010160c:	ff 45 e4             	incl   -0x1c(%ebp)
8010160f:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
80101613:	7e cf                	jle    801015e4 <iinit+0x2d>
    initsleeplock(&icache.inode[i].lock, "inode");
  }
  
  readsb(dev, &sb);
80101615:	c7 44 24 04 80 1a 11 	movl   $0x80111a80,0x4(%esp)
8010161c:	80 
8010161d:	8b 45 08             	mov    0x8(%ebp),%eax
80101620:	89 04 24             	mov    %eax,(%esp)
80101623:	e8 f4 fc ff ff       	call   8010131c <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
80101628:	a1 98 1a 11 80       	mov    0x80111a98,%eax
8010162d:	8b 3d 94 1a 11 80    	mov    0x80111a94,%edi
80101633:	8b 35 90 1a 11 80    	mov    0x80111a90,%esi
80101639:	8b 1d 8c 1a 11 80    	mov    0x80111a8c,%ebx
8010163f:	8b 0d 88 1a 11 80    	mov    0x80111a88,%ecx
80101645:	8b 15 84 1a 11 80    	mov    0x80111a84,%edx
8010164b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
8010164e:	8b 15 80 1a 11 80    	mov    0x80111a80,%edx
80101654:	89 44 24 1c          	mov    %eax,0x1c(%esp)
80101658:	89 7c 24 18          	mov    %edi,0x18(%esp)
8010165c:	89 74 24 14          	mov    %esi,0x14(%esp)
80101660:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80101664:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101668:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010166b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010166f:	89 d0                	mov    %edx,%eax
80101671:	89 44 24 04          	mov    %eax,0x4(%esp)
80101675:	c7 04 24 30 86 10 80 	movl   $0x80108630,(%esp)
8010167c:	e8 40 ed ff ff       	call   801003c1 <cprintf>
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
80101681:	83 c4 4c             	add    $0x4c,%esp
80101684:	5b                   	pop    %ebx
80101685:	5e                   	pop    %esi
80101686:	5f                   	pop    %edi
80101687:	5d                   	pop    %ebp
80101688:	c3                   	ret    

80101689 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
80101689:	55                   	push   %ebp
8010168a:	89 e5                	mov    %esp,%ebp
8010168c:	83 ec 28             	sub    $0x28,%esp
8010168f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101692:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101696:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
8010169d:	e9 9b 00 00 00       	jmp    8010173d <ialloc+0xb4>
    bp = bread(dev, IBLOCK(inum, sb));
801016a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016a5:	c1 e8 03             	shr    $0x3,%eax
801016a8:	89 c2                	mov    %eax,%edx
801016aa:	a1 94 1a 11 80       	mov    0x80111a94,%eax
801016af:	01 d0                	add    %edx,%eax
801016b1:	89 44 24 04          	mov    %eax,0x4(%esp)
801016b5:	8b 45 08             	mov    0x8(%ebp),%eax
801016b8:	89 04 24             	mov    %eax,(%esp)
801016bb:	e8 f5 ea ff ff       	call   801001b5 <bread>
801016c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801016c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016c6:	8d 50 5c             	lea    0x5c(%eax),%edx
801016c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016cc:	83 e0 07             	and    $0x7,%eax
801016cf:	c1 e0 06             	shl    $0x6,%eax
801016d2:	01 d0                	add    %edx,%eax
801016d4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
801016d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801016da:	8b 00                	mov    (%eax),%eax
801016dc:	66 85 c0             	test   %ax,%ax
801016df:	75 4e                	jne    8010172f <ialloc+0xa6>
      memset(dip, 0, sizeof(*dip));
801016e1:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
801016e8:	00 
801016e9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801016f0:	00 
801016f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801016f4:	89 04 24             	mov    %eax,(%esp)
801016f7:	e8 8e 3a 00 00       	call   8010518a <memset>
      dip->type = type;
801016fc:	8b 55 ec             	mov    -0x14(%ebp),%edx
801016ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101702:	66 89 02             	mov    %ax,(%edx)
      log_write(bp);   // mark it allocated on the disk
80101705:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101708:	89 04 24             	mov    %eax,(%esp)
8010170b:	e8 b7 1f 00 00       	call   801036c7 <log_write>
      brelse(bp);
80101710:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101713:	89 04 24             	mov    %eax,(%esp)
80101716:	e8 11 eb ff ff       	call   8010022c <brelse>
      return iget(dev, inum);
8010171b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010171e:	89 44 24 04          	mov    %eax,0x4(%esp)
80101722:	8b 45 08             	mov    0x8(%ebp),%eax
80101725:	89 04 24             	mov    %eax,(%esp)
80101728:	e8 ea 00 00 00       	call   80101817 <iget>
8010172d:	eb 2a                	jmp    80101759 <ialloc+0xd0>
    }
    brelse(bp);
8010172f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101732:	89 04 24             	mov    %eax,(%esp)
80101735:	e8 f2 ea ff ff       	call   8010022c <brelse>
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
8010173a:	ff 45 f4             	incl   -0xc(%ebp)
8010173d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101740:	a1 88 1a 11 80       	mov    0x80111a88,%eax
80101745:	39 c2                	cmp    %eax,%edx
80101747:	0f 82 55 ff ff ff    	jb     801016a2 <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
8010174d:	c7 04 24 83 86 10 80 	movl   $0x80108683,(%esp)
80101754:	e8 fb ed ff ff       	call   80100554 <panic>
}
80101759:	c9                   	leave  
8010175a:	c3                   	ret    

8010175b <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
8010175b:	55                   	push   %ebp
8010175c:	89 e5                	mov    %esp,%ebp
8010175e:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101761:	8b 45 08             	mov    0x8(%ebp),%eax
80101764:	8b 40 04             	mov    0x4(%eax),%eax
80101767:	c1 e8 03             	shr    $0x3,%eax
8010176a:	89 c2                	mov    %eax,%edx
8010176c:	a1 94 1a 11 80       	mov    0x80111a94,%eax
80101771:	01 c2                	add    %eax,%edx
80101773:	8b 45 08             	mov    0x8(%ebp),%eax
80101776:	8b 00                	mov    (%eax),%eax
80101778:	89 54 24 04          	mov    %edx,0x4(%esp)
8010177c:	89 04 24             	mov    %eax,(%esp)
8010177f:	e8 31 ea ff ff       	call   801001b5 <bread>
80101784:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101787:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010178a:	8d 50 5c             	lea    0x5c(%eax),%edx
8010178d:	8b 45 08             	mov    0x8(%ebp),%eax
80101790:	8b 40 04             	mov    0x4(%eax),%eax
80101793:	83 e0 07             	and    $0x7,%eax
80101796:	c1 e0 06             	shl    $0x6,%eax
80101799:	01 d0                	add    %edx,%eax
8010179b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
8010179e:	8b 45 08             	mov    0x8(%ebp),%eax
801017a1:	8b 40 50             	mov    0x50(%eax),%eax
801017a4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801017a7:	66 89 02             	mov    %ax,(%edx)
  dip->major = ip->major;
801017aa:	8b 45 08             	mov    0x8(%ebp),%eax
801017ad:	66 8b 40 52          	mov    0x52(%eax),%ax
801017b1:	8b 55 f0             	mov    -0x10(%ebp),%edx
801017b4:	66 89 42 02          	mov    %ax,0x2(%edx)
  dip->minor = ip->minor;
801017b8:	8b 45 08             	mov    0x8(%ebp),%eax
801017bb:	8b 40 54             	mov    0x54(%eax),%eax
801017be:	8b 55 f0             	mov    -0x10(%ebp),%edx
801017c1:	66 89 42 04          	mov    %ax,0x4(%edx)
  dip->nlink = ip->nlink;
801017c5:	8b 45 08             	mov    0x8(%ebp),%eax
801017c8:	66 8b 40 56          	mov    0x56(%eax),%ax
801017cc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801017cf:	66 89 42 06          	mov    %ax,0x6(%edx)
  dip->size = ip->size;
801017d3:	8b 45 08             	mov    0x8(%ebp),%eax
801017d6:	8b 50 58             	mov    0x58(%eax),%edx
801017d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017dc:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801017df:	8b 45 08             	mov    0x8(%ebp),%eax
801017e2:	8d 50 5c             	lea    0x5c(%eax),%edx
801017e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017e8:	83 c0 0c             	add    $0xc,%eax
801017eb:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
801017f2:	00 
801017f3:	89 54 24 04          	mov    %edx,0x4(%esp)
801017f7:	89 04 24             	mov    %eax,(%esp)
801017fa:	e8 54 3a 00 00       	call   80105253 <memmove>
  log_write(bp);
801017ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101802:	89 04 24             	mov    %eax,(%esp)
80101805:	e8 bd 1e 00 00       	call   801036c7 <log_write>
  brelse(bp);
8010180a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010180d:	89 04 24             	mov    %eax,(%esp)
80101810:	e8 17 ea ff ff       	call   8010022c <brelse>
}
80101815:	c9                   	leave  
80101816:	c3                   	ret    

80101817 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101817:	55                   	push   %ebp
80101818:	89 e5                	mov    %esp,%ebp
8010181a:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
8010181d:	c7 04 24 a0 1a 11 80 	movl   $0x80111aa0,(%esp)
80101824:	e8 fe 36 00 00       	call   80104f27 <acquire>

  // Is the inode already cached?
  empty = 0;
80101829:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101830:	c7 45 f4 d4 1a 11 80 	movl   $0x80111ad4,-0xc(%ebp)
80101837:	eb 5c                	jmp    80101895 <iget+0x7e>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101839:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010183c:	8b 40 08             	mov    0x8(%eax),%eax
8010183f:	85 c0                	test   %eax,%eax
80101841:	7e 35                	jle    80101878 <iget+0x61>
80101843:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101846:	8b 00                	mov    (%eax),%eax
80101848:	3b 45 08             	cmp    0x8(%ebp),%eax
8010184b:	75 2b                	jne    80101878 <iget+0x61>
8010184d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101850:	8b 40 04             	mov    0x4(%eax),%eax
80101853:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101856:	75 20                	jne    80101878 <iget+0x61>
      ip->ref++;
80101858:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010185b:	8b 40 08             	mov    0x8(%eax),%eax
8010185e:	8d 50 01             	lea    0x1(%eax),%edx
80101861:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101864:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101867:	c7 04 24 a0 1a 11 80 	movl   $0x80111aa0,(%esp)
8010186e:	e8 1b 37 00 00       	call   80104f8e <release>
      return ip;
80101873:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101876:	eb 72                	jmp    801018ea <iget+0xd3>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101878:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010187c:	75 10                	jne    8010188e <iget+0x77>
8010187e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101881:	8b 40 08             	mov    0x8(%eax),%eax
80101884:	85 c0                	test   %eax,%eax
80101886:	75 06                	jne    8010188e <iget+0x77>
      empty = ip;
80101888:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010188b:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010188e:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101895:	81 7d f4 f4 36 11 80 	cmpl   $0x801136f4,-0xc(%ebp)
8010189c:	72 9b                	jb     80101839 <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
8010189e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801018a2:	75 0c                	jne    801018b0 <iget+0x99>
    panic("iget: no inodes");
801018a4:	c7 04 24 95 86 10 80 	movl   $0x80108695,(%esp)
801018ab:	e8 a4 ec ff ff       	call   80100554 <panic>

  ip = empty;
801018b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
801018b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018b9:	8b 55 08             	mov    0x8(%ebp),%edx
801018bc:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
801018be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018c1:	8b 55 0c             	mov    0xc(%ebp),%edx
801018c4:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
801018c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ca:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
801018d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018d4:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
801018db:	c7 04 24 a0 1a 11 80 	movl   $0x80111aa0,(%esp)
801018e2:	e8 a7 36 00 00       	call   80104f8e <release>

  return ip;
801018e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801018ea:	c9                   	leave  
801018eb:	c3                   	ret    

801018ec <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801018ec:	55                   	push   %ebp
801018ed:	89 e5                	mov    %esp,%ebp
801018ef:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
801018f2:	c7 04 24 a0 1a 11 80 	movl   $0x80111aa0,(%esp)
801018f9:	e8 29 36 00 00       	call   80104f27 <acquire>
  ip->ref++;
801018fe:	8b 45 08             	mov    0x8(%ebp),%eax
80101901:	8b 40 08             	mov    0x8(%eax),%eax
80101904:	8d 50 01             	lea    0x1(%eax),%edx
80101907:	8b 45 08             	mov    0x8(%ebp),%eax
8010190a:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
8010190d:	c7 04 24 a0 1a 11 80 	movl   $0x80111aa0,(%esp)
80101914:	e8 75 36 00 00       	call   80104f8e <release>
  return ip;
80101919:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010191c:	c9                   	leave  
8010191d:	c3                   	ret    

8010191e <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
8010191e:	55                   	push   %ebp
8010191f:	89 e5                	mov    %esp,%ebp
80101921:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101924:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101928:	74 0a                	je     80101934 <ilock+0x16>
8010192a:	8b 45 08             	mov    0x8(%ebp),%eax
8010192d:	8b 40 08             	mov    0x8(%eax),%eax
80101930:	85 c0                	test   %eax,%eax
80101932:	7f 0c                	jg     80101940 <ilock+0x22>
    panic("ilock");
80101934:	c7 04 24 a5 86 10 80 	movl   $0x801086a5,(%esp)
8010193b:	e8 14 ec ff ff       	call   80100554 <panic>

  acquiresleep(&ip->lock);
80101940:	8b 45 08             	mov    0x8(%ebp),%eax
80101943:	83 c0 0c             	add    $0xc,%eax
80101946:	89 04 24             	mov    %eax,(%esp)
80101949:	e8 b4 34 00 00       	call   80104e02 <acquiresleep>

  if(!(ip->flags & I_VALID)){
8010194e:	8b 45 08             	mov    0x8(%ebp),%eax
80101951:	8b 40 4c             	mov    0x4c(%eax),%eax
80101954:	83 e0 02             	and    $0x2,%eax
80101957:	85 c0                	test   %eax,%eax
80101959:	0f 85 d1 00 00 00    	jne    80101a30 <ilock+0x112>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010195f:	8b 45 08             	mov    0x8(%ebp),%eax
80101962:	8b 40 04             	mov    0x4(%eax),%eax
80101965:	c1 e8 03             	shr    $0x3,%eax
80101968:	89 c2                	mov    %eax,%edx
8010196a:	a1 94 1a 11 80       	mov    0x80111a94,%eax
8010196f:	01 c2                	add    %eax,%edx
80101971:	8b 45 08             	mov    0x8(%ebp),%eax
80101974:	8b 00                	mov    (%eax),%eax
80101976:	89 54 24 04          	mov    %edx,0x4(%esp)
8010197a:	89 04 24             	mov    %eax,(%esp)
8010197d:	e8 33 e8 ff ff       	call   801001b5 <bread>
80101982:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101985:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101988:	8d 50 5c             	lea    0x5c(%eax),%edx
8010198b:	8b 45 08             	mov    0x8(%ebp),%eax
8010198e:	8b 40 04             	mov    0x4(%eax),%eax
80101991:	83 e0 07             	and    $0x7,%eax
80101994:	c1 e0 06             	shl    $0x6,%eax
80101997:	01 d0                	add    %edx,%eax
80101999:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
8010199c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010199f:	8b 00                	mov    (%eax),%eax
801019a1:	8b 55 08             	mov    0x8(%ebp),%edx
801019a4:	66 89 42 50          	mov    %ax,0x50(%edx)
    ip->major = dip->major;
801019a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019ab:	66 8b 40 02          	mov    0x2(%eax),%ax
801019af:	8b 55 08             	mov    0x8(%ebp),%edx
801019b2:	66 89 42 52          	mov    %ax,0x52(%edx)
    ip->minor = dip->minor;
801019b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019b9:	8b 40 04             	mov    0x4(%eax),%eax
801019bc:	8b 55 08             	mov    0x8(%ebp),%edx
801019bf:	66 89 42 54          	mov    %ax,0x54(%edx)
    ip->nlink = dip->nlink;
801019c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019c6:	66 8b 40 06          	mov    0x6(%eax),%ax
801019ca:	8b 55 08             	mov    0x8(%ebp),%edx
801019cd:	66 89 42 56          	mov    %ax,0x56(%edx)
    ip->size = dip->size;
801019d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019d4:	8b 50 08             	mov    0x8(%eax),%edx
801019d7:	8b 45 08             	mov    0x8(%ebp),%eax
801019da:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
801019dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019e0:	8d 50 0c             	lea    0xc(%eax),%edx
801019e3:	8b 45 08             	mov    0x8(%ebp),%eax
801019e6:	83 c0 5c             	add    $0x5c,%eax
801019e9:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
801019f0:	00 
801019f1:	89 54 24 04          	mov    %edx,0x4(%esp)
801019f5:	89 04 24             	mov    %eax,(%esp)
801019f8:	e8 56 38 00 00       	call   80105253 <memmove>
    brelse(bp);
801019fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a00:	89 04 24             	mov    %eax,(%esp)
80101a03:	e8 24 e8 ff ff       	call   8010022c <brelse>
    ip->flags |= I_VALID;
80101a08:	8b 45 08             	mov    0x8(%ebp),%eax
80101a0b:	8b 40 4c             	mov    0x4c(%eax),%eax
80101a0e:	83 c8 02             	or     $0x2,%eax
80101a11:	89 c2                	mov    %eax,%edx
80101a13:	8b 45 08             	mov    0x8(%ebp),%eax
80101a16:	89 50 4c             	mov    %edx,0x4c(%eax)
    if(ip->type == 0)
80101a19:	8b 45 08             	mov    0x8(%ebp),%eax
80101a1c:	8b 40 50             	mov    0x50(%eax),%eax
80101a1f:	66 85 c0             	test   %ax,%ax
80101a22:	75 0c                	jne    80101a30 <ilock+0x112>
      panic("ilock: no type");
80101a24:	c7 04 24 ab 86 10 80 	movl   $0x801086ab,(%esp)
80101a2b:	e8 24 eb ff ff       	call   80100554 <panic>
  }
}
80101a30:	c9                   	leave  
80101a31:	c3                   	ret    

80101a32 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101a32:	55                   	push   %ebp
80101a33:	89 e5                	mov    %esp,%ebp
80101a35:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101a38:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101a3c:	74 1c                	je     80101a5a <iunlock+0x28>
80101a3e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a41:	83 c0 0c             	add    $0xc,%eax
80101a44:	89 04 24             	mov    %eax,(%esp)
80101a47:	e8 54 34 00 00       	call   80104ea0 <holdingsleep>
80101a4c:	85 c0                	test   %eax,%eax
80101a4e:	74 0a                	je     80101a5a <iunlock+0x28>
80101a50:	8b 45 08             	mov    0x8(%ebp),%eax
80101a53:	8b 40 08             	mov    0x8(%eax),%eax
80101a56:	85 c0                	test   %eax,%eax
80101a58:	7f 0c                	jg     80101a66 <iunlock+0x34>
    panic("iunlock");
80101a5a:	c7 04 24 ba 86 10 80 	movl   $0x801086ba,(%esp)
80101a61:	e8 ee ea ff ff       	call   80100554 <panic>

  releasesleep(&ip->lock);
80101a66:	8b 45 08             	mov    0x8(%ebp),%eax
80101a69:	83 c0 0c             	add    $0xc,%eax
80101a6c:	89 04 24             	mov    %eax,(%esp)
80101a6f:	e8 ea 33 00 00       	call   80104e5e <releasesleep>
}
80101a74:	c9                   	leave  
80101a75:	c3                   	ret    

80101a76 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101a76:	55                   	push   %ebp
80101a77:	89 e5                	mov    %esp,%ebp
80101a79:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101a7c:	c7 04 24 a0 1a 11 80 	movl   $0x80111aa0,(%esp)
80101a83:	e8 9f 34 00 00       	call   80104f27 <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101a88:	8b 45 08             	mov    0x8(%ebp),%eax
80101a8b:	8b 40 08             	mov    0x8(%eax),%eax
80101a8e:	83 f8 01             	cmp    $0x1,%eax
80101a91:	75 5a                	jne    80101aed <iput+0x77>
80101a93:	8b 45 08             	mov    0x8(%ebp),%eax
80101a96:	8b 40 4c             	mov    0x4c(%eax),%eax
80101a99:	83 e0 02             	and    $0x2,%eax
80101a9c:	85 c0                	test   %eax,%eax
80101a9e:	74 4d                	je     80101aed <iput+0x77>
80101aa0:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa3:	66 8b 40 56          	mov    0x56(%eax),%ax
80101aa7:	66 85 c0             	test   %ax,%ax
80101aaa:	75 41                	jne    80101aed <iput+0x77>
    // inode has no links and no other references: truncate and free.
    release(&icache.lock);
80101aac:	c7 04 24 a0 1a 11 80 	movl   $0x80111aa0,(%esp)
80101ab3:	e8 d6 34 00 00       	call   80104f8e <release>
    itrunc(ip);
80101ab8:	8b 45 08             	mov    0x8(%ebp),%eax
80101abb:	89 04 24             	mov    %eax,(%esp)
80101abe:	e8 78 01 00 00       	call   80101c3b <itrunc>
    ip->type = 0;
80101ac3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac6:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
    iupdate(ip);
80101acc:	8b 45 08             	mov    0x8(%ebp),%eax
80101acf:	89 04 24             	mov    %eax,(%esp)
80101ad2:	e8 84 fc ff ff       	call   8010175b <iupdate>
    acquire(&icache.lock);
80101ad7:	c7 04 24 a0 1a 11 80 	movl   $0x80111aa0,(%esp)
80101ade:	e8 44 34 00 00       	call   80104f27 <acquire>
    ip->flags = 0;
80101ae3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae6:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }
  ip->ref--;
80101aed:	8b 45 08             	mov    0x8(%ebp),%eax
80101af0:	8b 40 08             	mov    0x8(%eax),%eax
80101af3:	8d 50 ff             	lea    -0x1(%eax),%edx
80101af6:	8b 45 08             	mov    0x8(%ebp),%eax
80101af9:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101afc:	c7 04 24 a0 1a 11 80 	movl   $0x80111aa0,(%esp)
80101b03:	e8 86 34 00 00       	call   80104f8e <release>
}
80101b08:	c9                   	leave  
80101b09:	c3                   	ret    

80101b0a <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101b0a:	55                   	push   %ebp
80101b0b:	89 e5                	mov    %esp,%ebp
80101b0d:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101b10:	8b 45 08             	mov    0x8(%ebp),%eax
80101b13:	89 04 24             	mov    %eax,(%esp)
80101b16:	e8 17 ff ff ff       	call   80101a32 <iunlock>
  iput(ip);
80101b1b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b1e:	89 04 24             	mov    %eax,(%esp)
80101b21:	e8 50 ff ff ff       	call   80101a76 <iput>
}
80101b26:	c9                   	leave  
80101b27:	c3                   	ret    

80101b28 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101b28:	55                   	push   %ebp
80101b29:	89 e5                	mov    %esp,%ebp
80101b2b:	53                   	push   %ebx
80101b2c:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101b2f:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101b33:	77 3e                	ja     80101b73 <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101b35:	8b 45 08             	mov    0x8(%ebp),%eax
80101b38:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b3b:	83 c2 14             	add    $0x14,%edx
80101b3e:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101b42:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b45:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101b49:	75 20                	jne    80101b6b <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101b4b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b4e:	8b 00                	mov    (%eax),%eax
80101b50:	89 04 24             	mov    %eax,(%esp)
80101b53:	e8 5b f8 ff ff       	call   801013b3 <balloc>
80101b58:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b5b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b5e:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b61:	8d 4a 14             	lea    0x14(%edx),%ecx
80101b64:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b67:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101b6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b6e:	e9 c2 00 00 00       	jmp    80101c35 <bmap+0x10d>
  }
  bn -= NDIRECT;
80101b73:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101b77:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101b7b:	0f 87 a8 00 00 00    	ja     80101c29 <bmap+0x101>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101b81:	8b 45 08             	mov    0x8(%ebp),%eax
80101b84:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101b8a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b8d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101b91:	75 1c                	jne    80101baf <bmap+0x87>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101b93:	8b 45 08             	mov    0x8(%ebp),%eax
80101b96:	8b 00                	mov    (%eax),%eax
80101b98:	89 04 24             	mov    %eax,(%esp)
80101b9b:	e8 13 f8 ff ff       	call   801013b3 <balloc>
80101ba0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ba3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ba9:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101baf:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb2:	8b 00                	mov    (%eax),%eax
80101bb4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101bb7:	89 54 24 04          	mov    %edx,0x4(%esp)
80101bbb:	89 04 24             	mov    %eax,(%esp)
80101bbe:	e8 f2 e5 ff ff       	call   801001b5 <bread>
80101bc3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101bc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bc9:	83 c0 5c             	add    $0x5c,%eax
80101bcc:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101bcf:	8b 45 0c             	mov    0xc(%ebp),%eax
80101bd2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101bd9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101bdc:	01 d0                	add    %edx,%eax
80101bde:	8b 00                	mov    (%eax),%eax
80101be0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101be3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101be7:	75 30                	jne    80101c19 <bmap+0xf1>
      a[bn] = addr = balloc(ip->dev);
80101be9:	8b 45 0c             	mov    0xc(%ebp),%eax
80101bec:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101bf3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101bf6:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101bf9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfc:	8b 00                	mov    (%eax),%eax
80101bfe:	89 04 24             	mov    %eax,(%esp)
80101c01:	e8 ad f7 ff ff       	call   801013b3 <balloc>
80101c06:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c0c:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101c0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c11:	89 04 24             	mov    %eax,(%esp)
80101c14:	e8 ae 1a 00 00       	call   801036c7 <log_write>
    }
    brelse(bp);
80101c19:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c1c:	89 04 24             	mov    %eax,(%esp)
80101c1f:	e8 08 e6 ff ff       	call   8010022c <brelse>
    return addr;
80101c24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c27:	eb 0c                	jmp    80101c35 <bmap+0x10d>
  }

  panic("bmap: out of range");
80101c29:	c7 04 24 c2 86 10 80 	movl   $0x801086c2,(%esp)
80101c30:	e8 1f e9 ff ff       	call   80100554 <panic>
}
80101c35:	83 c4 24             	add    $0x24,%esp
80101c38:	5b                   	pop    %ebx
80101c39:	5d                   	pop    %ebp
80101c3a:	c3                   	ret    

80101c3b <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101c3b:	55                   	push   %ebp
80101c3c:	89 e5                	mov    %esp,%ebp
80101c3e:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101c41:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101c48:	eb 43                	jmp    80101c8d <itrunc+0x52>
    if(ip->addrs[i]){
80101c4a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c50:	83 c2 14             	add    $0x14,%edx
80101c53:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c57:	85 c0                	test   %eax,%eax
80101c59:	74 2f                	je     80101c8a <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101c5b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c5e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c61:	83 c2 14             	add    $0x14,%edx
80101c64:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101c68:	8b 45 08             	mov    0x8(%ebp),%eax
80101c6b:	8b 00                	mov    (%eax),%eax
80101c6d:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c71:	89 04 24             	mov    %eax,(%esp)
80101c74:	e8 74 f8 ff ff       	call   801014ed <bfree>
      ip->addrs[i] = 0;
80101c79:	8b 45 08             	mov    0x8(%ebp),%eax
80101c7c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c7f:	83 c2 14             	add    $0x14,%edx
80101c82:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101c89:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101c8a:	ff 45 f4             	incl   -0xc(%ebp)
80101c8d:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101c91:	7e b7                	jle    80101c4a <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }

  if(ip->addrs[NDIRECT]){
80101c93:	8b 45 08             	mov    0x8(%ebp),%eax
80101c96:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101c9c:	85 c0                	test   %eax,%eax
80101c9e:	0f 84 a3 00 00 00    	je     80101d47 <itrunc+0x10c>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101ca4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca7:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101cad:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb0:	8b 00                	mov    (%eax),%eax
80101cb2:	89 54 24 04          	mov    %edx,0x4(%esp)
80101cb6:	89 04 24             	mov    %eax,(%esp)
80101cb9:	e8 f7 e4 ff ff       	call   801001b5 <bread>
80101cbe:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101cc1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101cc4:	83 c0 5c             	add    $0x5c,%eax
80101cc7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101cca:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101cd1:	eb 3a                	jmp    80101d0d <itrunc+0xd2>
      if(a[j])
80101cd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cd6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101cdd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101ce0:	01 d0                	add    %edx,%eax
80101ce2:	8b 00                	mov    (%eax),%eax
80101ce4:	85 c0                	test   %eax,%eax
80101ce6:	74 22                	je     80101d0a <itrunc+0xcf>
        bfree(ip->dev, a[j]);
80101ce8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ceb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101cf2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101cf5:	01 d0                	add    %edx,%eax
80101cf7:	8b 10                	mov    (%eax),%edx
80101cf9:	8b 45 08             	mov    0x8(%ebp),%eax
80101cfc:	8b 00                	mov    (%eax),%eax
80101cfe:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d02:	89 04 24             	mov    %eax,(%esp)
80101d05:	e8 e3 f7 ff ff       	call   801014ed <bfree>
  }

  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101d0a:	ff 45 f0             	incl   -0x10(%ebp)
80101d0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d10:	83 f8 7f             	cmp    $0x7f,%eax
80101d13:	76 be                	jbe    80101cd3 <itrunc+0x98>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101d15:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d18:	89 04 24             	mov    %eax,(%esp)
80101d1b:	e8 0c e5 ff ff       	call   8010022c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101d20:	8b 45 08             	mov    0x8(%ebp),%eax
80101d23:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101d29:	8b 45 08             	mov    0x8(%ebp),%eax
80101d2c:	8b 00                	mov    (%eax),%eax
80101d2e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d32:	89 04 24             	mov    %eax,(%esp)
80101d35:	e8 b3 f7 ff ff       	call   801014ed <bfree>
    ip->addrs[NDIRECT] = 0;
80101d3a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d3d:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101d44:	00 00 00 
  }

  ip->size = 0;
80101d47:	8b 45 08             	mov    0x8(%ebp),%eax
80101d4a:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101d51:	8b 45 08             	mov    0x8(%ebp),%eax
80101d54:	89 04 24             	mov    %eax,(%esp)
80101d57:	e8 ff f9 ff ff       	call   8010175b <iupdate>
}
80101d5c:	c9                   	leave  
80101d5d:	c3                   	ret    

80101d5e <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101d5e:	55                   	push   %ebp
80101d5f:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101d61:	8b 45 08             	mov    0x8(%ebp),%eax
80101d64:	8b 00                	mov    (%eax),%eax
80101d66:	89 c2                	mov    %eax,%edx
80101d68:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d6b:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101d6e:	8b 45 08             	mov    0x8(%ebp),%eax
80101d71:	8b 50 04             	mov    0x4(%eax),%edx
80101d74:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d77:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101d7a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d7d:	8b 40 50             	mov    0x50(%eax),%eax
80101d80:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d83:	66 89 02             	mov    %ax,(%edx)
  st->nlink = ip->nlink;
80101d86:	8b 45 08             	mov    0x8(%ebp),%eax
80101d89:	66 8b 40 56          	mov    0x56(%eax),%ax
80101d8d:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d90:	66 89 42 0c          	mov    %ax,0xc(%edx)
  st->size = ip->size;
80101d94:	8b 45 08             	mov    0x8(%ebp),%eax
80101d97:	8b 50 58             	mov    0x58(%eax),%edx
80101d9a:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d9d:	89 50 10             	mov    %edx,0x10(%eax)
}
80101da0:	5d                   	pop    %ebp
80101da1:	c3                   	ret    

80101da2 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101da2:	55                   	push   %ebp
80101da3:	89 e5                	mov    %esp,%ebp
80101da5:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101da8:	8b 45 08             	mov    0x8(%ebp),%eax
80101dab:	8b 40 50             	mov    0x50(%eax),%eax
80101dae:	66 83 f8 03          	cmp    $0x3,%ax
80101db2:	75 60                	jne    80101e14 <readi+0x72>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101db4:	8b 45 08             	mov    0x8(%ebp),%eax
80101db7:	66 8b 40 52          	mov    0x52(%eax),%ax
80101dbb:	66 85 c0             	test   %ax,%ax
80101dbe:	78 20                	js     80101de0 <readi+0x3e>
80101dc0:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc3:	66 8b 40 52          	mov    0x52(%eax),%ax
80101dc7:	66 83 f8 09          	cmp    $0x9,%ax
80101dcb:	7f 13                	jg     80101de0 <readi+0x3e>
80101dcd:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd0:	66 8b 40 52          	mov    0x52(%eax),%ax
80101dd4:	98                   	cwtl   
80101dd5:	8b 04 c5 20 1a 11 80 	mov    -0x7feee5e0(,%eax,8),%eax
80101ddc:	85 c0                	test   %eax,%eax
80101dde:	75 0a                	jne    80101dea <readi+0x48>
      return -1;
80101de0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101de5:	e9 1a 01 00 00       	jmp    80101f04 <readi+0x162>
    return devsw[ip->major].read(ip, dst, n);
80101dea:	8b 45 08             	mov    0x8(%ebp),%eax
80101ded:	66 8b 40 52          	mov    0x52(%eax),%ax
80101df1:	98                   	cwtl   
80101df2:	8b 04 c5 20 1a 11 80 	mov    -0x7feee5e0(,%eax,8),%eax
80101df9:	8b 55 14             	mov    0x14(%ebp),%edx
80101dfc:	89 54 24 08          	mov    %edx,0x8(%esp)
80101e00:	8b 55 0c             	mov    0xc(%ebp),%edx
80101e03:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e07:	8b 55 08             	mov    0x8(%ebp),%edx
80101e0a:	89 14 24             	mov    %edx,(%esp)
80101e0d:	ff d0                	call   *%eax
80101e0f:	e9 f0 00 00 00       	jmp    80101f04 <readi+0x162>
  }

  if(off > ip->size || off + n < off)
80101e14:	8b 45 08             	mov    0x8(%ebp),%eax
80101e17:	8b 40 58             	mov    0x58(%eax),%eax
80101e1a:	3b 45 10             	cmp    0x10(%ebp),%eax
80101e1d:	72 0d                	jb     80101e2c <readi+0x8a>
80101e1f:	8b 45 14             	mov    0x14(%ebp),%eax
80101e22:	8b 55 10             	mov    0x10(%ebp),%edx
80101e25:	01 d0                	add    %edx,%eax
80101e27:	3b 45 10             	cmp    0x10(%ebp),%eax
80101e2a:	73 0a                	jae    80101e36 <readi+0x94>
    return -1;
80101e2c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101e31:	e9 ce 00 00 00       	jmp    80101f04 <readi+0x162>
  if(off + n > ip->size)
80101e36:	8b 45 14             	mov    0x14(%ebp),%eax
80101e39:	8b 55 10             	mov    0x10(%ebp),%edx
80101e3c:	01 c2                	add    %eax,%edx
80101e3e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e41:	8b 40 58             	mov    0x58(%eax),%eax
80101e44:	39 c2                	cmp    %eax,%edx
80101e46:	76 0c                	jbe    80101e54 <readi+0xb2>
    n = ip->size - off;
80101e48:	8b 45 08             	mov    0x8(%ebp),%eax
80101e4b:	8b 40 58             	mov    0x58(%eax),%eax
80101e4e:	2b 45 10             	sub    0x10(%ebp),%eax
80101e51:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101e54:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101e5b:	e9 95 00 00 00       	jmp    80101ef5 <readi+0x153>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101e60:	8b 45 10             	mov    0x10(%ebp),%eax
80101e63:	c1 e8 09             	shr    $0x9,%eax
80101e66:	89 44 24 04          	mov    %eax,0x4(%esp)
80101e6a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e6d:	89 04 24             	mov    %eax,(%esp)
80101e70:	e8 b3 fc ff ff       	call   80101b28 <bmap>
80101e75:	8b 55 08             	mov    0x8(%ebp),%edx
80101e78:	8b 12                	mov    (%edx),%edx
80101e7a:	89 44 24 04          	mov    %eax,0x4(%esp)
80101e7e:	89 14 24             	mov    %edx,(%esp)
80101e81:	e8 2f e3 ff ff       	call   801001b5 <bread>
80101e86:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101e89:	8b 45 10             	mov    0x10(%ebp),%eax
80101e8c:	25 ff 01 00 00       	and    $0x1ff,%eax
80101e91:	89 c2                	mov    %eax,%edx
80101e93:	b8 00 02 00 00       	mov    $0x200,%eax
80101e98:	29 d0                	sub    %edx,%eax
80101e9a:	89 c1                	mov    %eax,%ecx
80101e9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e9f:	8b 55 14             	mov    0x14(%ebp),%edx
80101ea2:	29 c2                	sub    %eax,%edx
80101ea4:	89 c8                	mov    %ecx,%eax
80101ea6:	39 d0                	cmp    %edx,%eax
80101ea8:	76 02                	jbe    80101eac <readi+0x10a>
80101eaa:	89 d0                	mov    %edx,%eax
80101eac:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for (int j = 0; j < min(m, 10); j++) {
      cprintf("%x ", bp->data[off%BSIZE+j]);
    }
    cprintf("\n");
    */
    memmove(dst, bp->data + off%BSIZE, m);
80101eaf:	8b 45 10             	mov    0x10(%ebp),%eax
80101eb2:	25 ff 01 00 00       	and    $0x1ff,%eax
80101eb7:	8d 50 50             	lea    0x50(%eax),%edx
80101eba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ebd:	01 d0                	add    %edx,%eax
80101ebf:	8d 50 0c             	lea    0xc(%eax),%edx
80101ec2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ec5:	89 44 24 08          	mov    %eax,0x8(%esp)
80101ec9:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ecd:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ed0:	89 04 24             	mov    %eax,(%esp)
80101ed3:	e8 7b 33 00 00       	call   80105253 <memmove>
    brelse(bp);
80101ed8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101edb:	89 04 24             	mov    %eax,(%esp)
80101ede:	e8 49 e3 ff ff       	call   8010022c <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101ee3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ee6:	01 45 f4             	add    %eax,-0xc(%ebp)
80101ee9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101eec:	01 45 10             	add    %eax,0x10(%ebp)
80101eef:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ef2:	01 45 0c             	add    %eax,0xc(%ebp)
80101ef5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ef8:	3b 45 14             	cmp    0x14(%ebp),%eax
80101efb:	0f 82 5f ff ff ff    	jb     80101e60 <readi+0xbe>
    cprintf("\n");
    */
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80101f01:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101f04:	c9                   	leave  
80101f05:	c3                   	ret    

80101f06 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101f06:	55                   	push   %ebp
80101f07:	89 e5                	mov    %esp,%ebp
80101f09:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101f0c:	8b 45 08             	mov    0x8(%ebp),%eax
80101f0f:	8b 40 50             	mov    0x50(%eax),%eax
80101f12:	66 83 f8 03          	cmp    $0x3,%ax
80101f16:	75 60                	jne    80101f78 <writei+0x72>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101f18:	8b 45 08             	mov    0x8(%ebp),%eax
80101f1b:	66 8b 40 52          	mov    0x52(%eax),%ax
80101f1f:	66 85 c0             	test   %ax,%ax
80101f22:	78 20                	js     80101f44 <writei+0x3e>
80101f24:	8b 45 08             	mov    0x8(%ebp),%eax
80101f27:	66 8b 40 52          	mov    0x52(%eax),%ax
80101f2b:	66 83 f8 09          	cmp    $0x9,%ax
80101f2f:	7f 13                	jg     80101f44 <writei+0x3e>
80101f31:	8b 45 08             	mov    0x8(%ebp),%eax
80101f34:	66 8b 40 52          	mov    0x52(%eax),%ax
80101f38:	98                   	cwtl   
80101f39:	8b 04 c5 24 1a 11 80 	mov    -0x7feee5dc(,%eax,8),%eax
80101f40:	85 c0                	test   %eax,%eax
80101f42:	75 0a                	jne    80101f4e <writei+0x48>
      return -1;
80101f44:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f49:	e9 45 01 00 00       	jmp    80102093 <writei+0x18d>
    return devsw[ip->major].write(ip, src, n);
80101f4e:	8b 45 08             	mov    0x8(%ebp),%eax
80101f51:	66 8b 40 52          	mov    0x52(%eax),%ax
80101f55:	98                   	cwtl   
80101f56:	8b 04 c5 24 1a 11 80 	mov    -0x7feee5dc(,%eax,8),%eax
80101f5d:	8b 55 14             	mov    0x14(%ebp),%edx
80101f60:	89 54 24 08          	mov    %edx,0x8(%esp)
80101f64:	8b 55 0c             	mov    0xc(%ebp),%edx
80101f67:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f6b:	8b 55 08             	mov    0x8(%ebp),%edx
80101f6e:	89 14 24             	mov    %edx,(%esp)
80101f71:	ff d0                	call   *%eax
80101f73:	e9 1b 01 00 00       	jmp    80102093 <writei+0x18d>
  }

  if(off > ip->size || off + n < off)
80101f78:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7b:	8b 40 58             	mov    0x58(%eax),%eax
80101f7e:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f81:	72 0d                	jb     80101f90 <writei+0x8a>
80101f83:	8b 45 14             	mov    0x14(%ebp),%eax
80101f86:	8b 55 10             	mov    0x10(%ebp),%edx
80101f89:	01 d0                	add    %edx,%eax
80101f8b:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f8e:	73 0a                	jae    80101f9a <writei+0x94>
    return -1;
80101f90:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f95:	e9 f9 00 00 00       	jmp    80102093 <writei+0x18d>
  if(off + n > MAXFILE*BSIZE)
80101f9a:	8b 45 14             	mov    0x14(%ebp),%eax
80101f9d:	8b 55 10             	mov    0x10(%ebp),%edx
80101fa0:	01 d0                	add    %edx,%eax
80101fa2:	3d 00 18 01 00       	cmp    $0x11800,%eax
80101fa7:	76 0a                	jbe    80101fb3 <writei+0xad>
    return -1;
80101fa9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fae:	e9 e0 00 00 00       	jmp    80102093 <writei+0x18d>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101fb3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101fba:	e9 a0 00 00 00       	jmp    8010205f <writei+0x159>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101fbf:	8b 45 10             	mov    0x10(%ebp),%eax
80101fc2:	c1 e8 09             	shr    $0x9,%eax
80101fc5:	89 44 24 04          	mov    %eax,0x4(%esp)
80101fc9:	8b 45 08             	mov    0x8(%ebp),%eax
80101fcc:	89 04 24             	mov    %eax,(%esp)
80101fcf:	e8 54 fb ff ff       	call   80101b28 <bmap>
80101fd4:	8b 55 08             	mov    0x8(%ebp),%edx
80101fd7:	8b 12                	mov    (%edx),%edx
80101fd9:	89 44 24 04          	mov    %eax,0x4(%esp)
80101fdd:	89 14 24             	mov    %edx,(%esp)
80101fe0:	e8 d0 e1 ff ff       	call   801001b5 <bread>
80101fe5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fe8:	8b 45 10             	mov    0x10(%ebp),%eax
80101feb:	25 ff 01 00 00       	and    $0x1ff,%eax
80101ff0:	89 c2                	mov    %eax,%edx
80101ff2:	b8 00 02 00 00       	mov    $0x200,%eax
80101ff7:	29 d0                	sub    %edx,%eax
80101ff9:	89 c1                	mov    %eax,%ecx
80101ffb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ffe:	8b 55 14             	mov    0x14(%ebp),%edx
80102001:	29 c2                	sub    %eax,%edx
80102003:	89 c8                	mov    %ecx,%eax
80102005:	39 d0                	cmp    %edx,%eax
80102007:	76 02                	jbe    8010200b <writei+0x105>
80102009:	89 d0                	mov    %edx,%eax
8010200b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
8010200e:	8b 45 10             	mov    0x10(%ebp),%eax
80102011:	25 ff 01 00 00       	and    $0x1ff,%eax
80102016:	8d 50 50             	lea    0x50(%eax),%edx
80102019:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010201c:	01 d0                	add    %edx,%eax
8010201e:	8d 50 0c             	lea    0xc(%eax),%edx
80102021:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102024:	89 44 24 08          	mov    %eax,0x8(%esp)
80102028:	8b 45 0c             	mov    0xc(%ebp),%eax
8010202b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010202f:	89 14 24             	mov    %edx,(%esp)
80102032:	e8 1c 32 00 00       	call   80105253 <memmove>
    log_write(bp);
80102037:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010203a:	89 04 24             	mov    %eax,(%esp)
8010203d:	e8 85 16 00 00       	call   801036c7 <log_write>
    brelse(bp);
80102042:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102045:	89 04 24             	mov    %eax,(%esp)
80102048:	e8 df e1 ff ff       	call   8010022c <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010204d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102050:	01 45 f4             	add    %eax,-0xc(%ebp)
80102053:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102056:	01 45 10             	add    %eax,0x10(%ebp)
80102059:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010205c:	01 45 0c             	add    %eax,0xc(%ebp)
8010205f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102062:	3b 45 14             	cmp    0x14(%ebp),%eax
80102065:	0f 82 54 ff ff ff    	jb     80101fbf <writei+0xb9>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
8010206b:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010206f:	74 1f                	je     80102090 <writei+0x18a>
80102071:	8b 45 08             	mov    0x8(%ebp),%eax
80102074:	8b 40 58             	mov    0x58(%eax),%eax
80102077:	3b 45 10             	cmp    0x10(%ebp),%eax
8010207a:	73 14                	jae    80102090 <writei+0x18a>
    ip->size = off;
8010207c:	8b 45 08             	mov    0x8(%ebp),%eax
8010207f:	8b 55 10             	mov    0x10(%ebp),%edx
80102082:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
80102085:	8b 45 08             	mov    0x8(%ebp),%eax
80102088:	89 04 24             	mov    %eax,(%esp)
8010208b:	e8 cb f6 ff ff       	call   8010175b <iupdate>
  }
  return n;
80102090:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102093:	c9                   	leave  
80102094:	c3                   	ret    

80102095 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102095:	55                   	push   %ebp
80102096:	89 e5                	mov    %esp,%ebp
80102098:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
8010209b:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801020a2:	00 
801020a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801020a6:	89 44 24 04          	mov    %eax,0x4(%esp)
801020aa:	8b 45 08             	mov    0x8(%ebp),%eax
801020ad:	89 04 24             	mov    %eax,(%esp)
801020b0:	e8 3d 32 00 00       	call   801052f2 <strncmp>
}
801020b5:	c9                   	leave  
801020b6:	c3                   	ret    

801020b7 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801020b7:	55                   	push   %ebp
801020b8:	89 e5                	mov    %esp,%ebp
801020ba:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801020bd:	8b 45 08             	mov    0x8(%ebp),%eax
801020c0:	8b 40 50             	mov    0x50(%eax),%eax
801020c3:	66 83 f8 01          	cmp    $0x1,%ax
801020c7:	74 0c                	je     801020d5 <dirlookup+0x1e>
    panic("dirlookup not DIR");
801020c9:	c7 04 24 d5 86 10 80 	movl   $0x801086d5,(%esp)
801020d0:	e8 7f e4 ff ff       	call   80100554 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801020d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020dc:	e9 86 00 00 00       	jmp    80102167 <dirlookup+0xb0>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801020e1:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801020e8:	00 
801020e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020ec:	89 44 24 08          	mov    %eax,0x8(%esp)
801020f0:	8d 45 e0             	lea    -0x20(%ebp),%eax
801020f3:	89 44 24 04          	mov    %eax,0x4(%esp)
801020f7:	8b 45 08             	mov    0x8(%ebp),%eax
801020fa:	89 04 24             	mov    %eax,(%esp)
801020fd:	e8 a0 fc ff ff       	call   80101da2 <readi>
80102102:	83 f8 10             	cmp    $0x10,%eax
80102105:	74 0c                	je     80102113 <dirlookup+0x5c>
      panic("dirlink read");
80102107:	c7 04 24 e7 86 10 80 	movl   $0x801086e7,(%esp)
8010210e:	e8 41 e4 ff ff       	call   80100554 <panic>
    if(de.inum == 0)
80102113:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102116:	66 85 c0             	test   %ax,%ax
80102119:	75 02                	jne    8010211d <dirlookup+0x66>
      continue;
8010211b:	eb 46                	jmp    80102163 <dirlookup+0xac>
    if(namecmp(name, de.name) == 0){
8010211d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102120:	83 c0 02             	add    $0x2,%eax
80102123:	89 44 24 04          	mov    %eax,0x4(%esp)
80102127:	8b 45 0c             	mov    0xc(%ebp),%eax
8010212a:	89 04 24             	mov    %eax,(%esp)
8010212d:	e8 63 ff ff ff       	call   80102095 <namecmp>
80102132:	85 c0                	test   %eax,%eax
80102134:	75 2d                	jne    80102163 <dirlookup+0xac>
      // entry matches path element
      if(poff)
80102136:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010213a:	74 08                	je     80102144 <dirlookup+0x8d>
        *poff = off;
8010213c:	8b 45 10             	mov    0x10(%ebp),%eax
8010213f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102142:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102144:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102147:	0f b7 c0             	movzwl %ax,%eax
8010214a:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
8010214d:	8b 45 08             	mov    0x8(%ebp),%eax
80102150:	8b 00                	mov    (%eax),%eax
80102152:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102155:	89 54 24 04          	mov    %edx,0x4(%esp)
80102159:	89 04 24             	mov    %eax,(%esp)
8010215c:	e8 b6 f6 ff ff       	call   80101817 <iget>
80102161:	eb 18                	jmp    8010217b <dirlookup+0xc4>
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102163:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102167:	8b 45 08             	mov    0x8(%ebp),%eax
8010216a:	8b 40 58             	mov    0x58(%eax),%eax
8010216d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102170:	0f 87 6b ff ff ff    	ja     801020e1 <dirlookup+0x2a>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
80102176:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010217b:	c9                   	leave  
8010217c:	c3                   	ret    

8010217d <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
8010217d:	55                   	push   %ebp
8010217e:	89 e5                	mov    %esp,%ebp
80102180:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102183:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010218a:	00 
8010218b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010218e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102192:	8b 45 08             	mov    0x8(%ebp),%eax
80102195:	89 04 24             	mov    %eax,(%esp)
80102198:	e8 1a ff ff ff       	call   801020b7 <dirlookup>
8010219d:	89 45 f0             	mov    %eax,-0x10(%ebp)
801021a0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801021a4:	74 15                	je     801021bb <dirlink+0x3e>
    iput(ip);
801021a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021a9:	89 04 24             	mov    %eax,(%esp)
801021ac:	e8 c5 f8 ff ff       	call   80101a76 <iput>
    return -1;
801021b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021b6:	e9 b6 00 00 00       	jmp    80102271 <dirlink+0xf4>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801021bb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021c2:	eb 45                	jmp    80102209 <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021c7:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801021ce:	00 
801021cf:	89 44 24 08          	mov    %eax,0x8(%esp)
801021d3:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021d6:	89 44 24 04          	mov    %eax,0x4(%esp)
801021da:	8b 45 08             	mov    0x8(%ebp),%eax
801021dd:	89 04 24             	mov    %eax,(%esp)
801021e0:	e8 bd fb ff ff       	call   80101da2 <readi>
801021e5:	83 f8 10             	cmp    $0x10,%eax
801021e8:	74 0c                	je     801021f6 <dirlink+0x79>
      panic("dirlink read");
801021ea:	c7 04 24 e7 86 10 80 	movl   $0x801086e7,(%esp)
801021f1:	e8 5e e3 ff ff       	call   80100554 <panic>
    if(de.inum == 0)
801021f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801021f9:	66 85 c0             	test   %ax,%ax
801021fc:	75 02                	jne    80102200 <dirlink+0x83>
      break;
801021fe:	eb 16                	jmp    80102216 <dirlink+0x99>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102200:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102203:	83 c0 10             	add    $0x10,%eax
80102206:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102209:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010220c:	8b 45 08             	mov    0x8(%ebp),%eax
8010220f:	8b 40 58             	mov    0x58(%eax),%eax
80102212:	39 c2                	cmp    %eax,%edx
80102214:	72 ae                	jb     801021c4 <dirlink+0x47>
      panic("dirlink read");
    if(de.inum == 0)
      break;
  }

  strncpy(de.name, name, DIRSIZ);
80102216:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
8010221d:	00 
8010221e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102221:	89 44 24 04          	mov    %eax,0x4(%esp)
80102225:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102228:	83 c0 02             	add    $0x2,%eax
8010222b:	89 04 24             	mov    %eax,(%esp)
8010222e:	e8 0d 31 00 00       	call   80105340 <strncpy>
  de.inum = inum;
80102233:	8b 45 10             	mov    0x10(%ebp),%eax
80102236:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010223a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010223d:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102244:	00 
80102245:	89 44 24 08          	mov    %eax,0x8(%esp)
80102249:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010224c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102250:	8b 45 08             	mov    0x8(%ebp),%eax
80102253:	89 04 24             	mov    %eax,(%esp)
80102256:	e8 ab fc ff ff       	call   80101f06 <writei>
8010225b:	83 f8 10             	cmp    $0x10,%eax
8010225e:	74 0c                	je     8010226c <dirlink+0xef>
    panic("dirlink");
80102260:	c7 04 24 f4 86 10 80 	movl   $0x801086f4,(%esp)
80102267:	e8 e8 e2 ff ff       	call   80100554 <panic>

  return 0;
8010226c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102271:	c9                   	leave  
80102272:	c3                   	ret    

80102273 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102273:	55                   	push   %ebp
80102274:	89 e5                	mov    %esp,%ebp
80102276:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
80102279:	eb 03                	jmp    8010227e <skipelem+0xb>
    path++;
8010227b:	ff 45 08             	incl   0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
8010227e:	8b 45 08             	mov    0x8(%ebp),%eax
80102281:	8a 00                	mov    (%eax),%al
80102283:	3c 2f                	cmp    $0x2f,%al
80102285:	74 f4                	je     8010227b <skipelem+0x8>
    path++;
  if(*path == 0)
80102287:	8b 45 08             	mov    0x8(%ebp),%eax
8010228a:	8a 00                	mov    (%eax),%al
8010228c:	84 c0                	test   %al,%al
8010228e:	75 0a                	jne    8010229a <skipelem+0x27>
    return 0;
80102290:	b8 00 00 00 00       	mov    $0x0,%eax
80102295:	e9 81 00 00 00       	jmp    8010231b <skipelem+0xa8>
  s = path;
8010229a:	8b 45 08             	mov    0x8(%ebp),%eax
8010229d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801022a0:	eb 03                	jmp    801022a5 <skipelem+0x32>
    path++;
801022a2:	ff 45 08             	incl   0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
801022a5:	8b 45 08             	mov    0x8(%ebp),%eax
801022a8:	8a 00                	mov    (%eax),%al
801022aa:	3c 2f                	cmp    $0x2f,%al
801022ac:	74 09                	je     801022b7 <skipelem+0x44>
801022ae:	8b 45 08             	mov    0x8(%ebp),%eax
801022b1:	8a 00                	mov    (%eax),%al
801022b3:	84 c0                	test   %al,%al
801022b5:	75 eb                	jne    801022a2 <skipelem+0x2f>
    path++;
  len = path - s;
801022b7:	8b 55 08             	mov    0x8(%ebp),%edx
801022ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022bd:	29 c2                	sub    %eax,%edx
801022bf:	89 d0                	mov    %edx,%eax
801022c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801022c4:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801022c8:	7e 1c                	jle    801022e6 <skipelem+0x73>
    memmove(name, s, DIRSIZ);
801022ca:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801022d1:	00 
801022d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022d5:	89 44 24 04          	mov    %eax,0x4(%esp)
801022d9:	8b 45 0c             	mov    0xc(%ebp),%eax
801022dc:	89 04 24             	mov    %eax,(%esp)
801022df:	e8 6f 2f 00 00       	call   80105253 <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801022e4:	eb 29                	jmp    8010230f <skipelem+0x9c>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
801022e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801022e9:	89 44 24 08          	mov    %eax,0x8(%esp)
801022ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022f0:	89 44 24 04          	mov    %eax,0x4(%esp)
801022f4:	8b 45 0c             	mov    0xc(%ebp),%eax
801022f7:	89 04 24             	mov    %eax,(%esp)
801022fa:	e8 54 2f 00 00       	call   80105253 <memmove>
    name[len] = 0;
801022ff:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102302:	8b 45 0c             	mov    0xc(%ebp),%eax
80102305:	01 d0                	add    %edx,%eax
80102307:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
8010230a:	eb 03                	jmp    8010230f <skipelem+0x9c>
    path++;
8010230c:	ff 45 08             	incl   0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
8010230f:	8b 45 08             	mov    0x8(%ebp),%eax
80102312:	8a 00                	mov    (%eax),%al
80102314:	3c 2f                	cmp    $0x2f,%al
80102316:	74 f4                	je     8010230c <skipelem+0x99>
    path++;
  return path;
80102318:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010231b:	c9                   	leave  
8010231c:	c3                   	ret    

8010231d <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
8010231d:	55                   	push   %ebp
8010231e:	89 e5                	mov    %esp,%ebp
80102320:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102323:	8b 45 08             	mov    0x8(%ebp),%eax
80102326:	8a 00                	mov    (%eax),%al
80102328:	3c 2f                	cmp    $0x2f,%al
8010232a:	75 1c                	jne    80102348 <namex+0x2b>
    ip = iget(ROOTDEV, ROOTINO);
8010232c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102333:	00 
80102334:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010233b:	e8 d7 f4 ff ff       	call   80101817 <iget>
80102340:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102343:	e9 ad 00 00 00       	jmp    801023f5 <namex+0xd8>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
80102348:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010234e:	8b 40 68             	mov    0x68(%eax),%eax
80102351:	89 04 24             	mov    %eax,(%esp)
80102354:	e8 93 f5 ff ff       	call   801018ec <idup>
80102359:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010235c:	e9 94 00 00 00       	jmp    801023f5 <namex+0xd8>
    ilock(ip);
80102361:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102364:	89 04 24             	mov    %eax,(%esp)
80102367:	e8 b2 f5 ff ff       	call   8010191e <ilock>
    if(ip->type != T_DIR){
8010236c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010236f:	8b 40 50             	mov    0x50(%eax),%eax
80102372:	66 83 f8 01          	cmp    $0x1,%ax
80102376:	74 15                	je     8010238d <namex+0x70>
      iunlockput(ip);
80102378:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010237b:	89 04 24             	mov    %eax,(%esp)
8010237e:	e8 87 f7 ff ff       	call   80101b0a <iunlockput>
      return 0;
80102383:	b8 00 00 00 00       	mov    $0x0,%eax
80102388:	e9 a2 00 00 00       	jmp    8010242f <namex+0x112>
    }
    if(nameiparent && *path == '\0'){
8010238d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102391:	74 1c                	je     801023af <namex+0x92>
80102393:	8b 45 08             	mov    0x8(%ebp),%eax
80102396:	8a 00                	mov    (%eax),%al
80102398:	84 c0                	test   %al,%al
8010239a:	75 13                	jne    801023af <namex+0x92>
      // Stop one level early.
      iunlock(ip);
8010239c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010239f:	89 04 24             	mov    %eax,(%esp)
801023a2:	e8 8b f6 ff ff       	call   80101a32 <iunlock>
      return ip;
801023a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023aa:	e9 80 00 00 00       	jmp    8010242f <namex+0x112>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801023af:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801023b6:	00 
801023b7:	8b 45 10             	mov    0x10(%ebp),%eax
801023ba:	89 44 24 04          	mov    %eax,0x4(%esp)
801023be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023c1:	89 04 24             	mov    %eax,(%esp)
801023c4:	e8 ee fc ff ff       	call   801020b7 <dirlookup>
801023c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801023cc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801023d0:	75 12                	jne    801023e4 <namex+0xc7>
      iunlockput(ip);
801023d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023d5:	89 04 24             	mov    %eax,(%esp)
801023d8:	e8 2d f7 ff ff       	call   80101b0a <iunlockput>
      return 0;
801023dd:	b8 00 00 00 00       	mov    $0x0,%eax
801023e2:	eb 4b                	jmp    8010242f <namex+0x112>
    }
    iunlockput(ip);
801023e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023e7:	89 04 24             	mov    %eax,(%esp)
801023ea:	e8 1b f7 ff ff       	call   80101b0a <iunlockput>
    ip = next;
801023ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
801023f5:	8b 45 10             	mov    0x10(%ebp),%eax
801023f8:	89 44 24 04          	mov    %eax,0x4(%esp)
801023fc:	8b 45 08             	mov    0x8(%ebp),%eax
801023ff:	89 04 24             	mov    %eax,(%esp)
80102402:	e8 6c fe ff ff       	call   80102273 <skipelem>
80102407:	89 45 08             	mov    %eax,0x8(%ebp)
8010240a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010240e:	0f 85 4d ff ff ff    	jne    80102361 <namex+0x44>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102414:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102418:	74 12                	je     8010242c <namex+0x10f>
    iput(ip);
8010241a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010241d:	89 04 24             	mov    %eax,(%esp)
80102420:	e8 51 f6 ff ff       	call   80101a76 <iput>
    return 0;
80102425:	b8 00 00 00 00       	mov    $0x0,%eax
8010242a:	eb 03                	jmp    8010242f <namex+0x112>
  }
  return ip;
8010242c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010242f:	c9                   	leave  
80102430:	c3                   	ret    

80102431 <namei>:

struct inode*
namei(char *path)
{
80102431:	55                   	push   %ebp
80102432:	89 e5                	mov    %esp,%ebp
80102434:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102437:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010243a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010243e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102445:	00 
80102446:	8b 45 08             	mov    0x8(%ebp),%eax
80102449:	89 04 24             	mov    %eax,(%esp)
8010244c:	e8 cc fe ff ff       	call   8010231d <namex>
}
80102451:	c9                   	leave  
80102452:	c3                   	ret    

80102453 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102453:	55                   	push   %ebp
80102454:	89 e5                	mov    %esp,%ebp
80102456:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
80102459:	8b 45 0c             	mov    0xc(%ebp),%eax
8010245c:	89 44 24 08          	mov    %eax,0x8(%esp)
80102460:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102467:	00 
80102468:	8b 45 08             	mov    0x8(%ebp),%eax
8010246b:	89 04 24             	mov    %eax,(%esp)
8010246e:	e8 aa fe ff ff       	call   8010231d <namex>
}
80102473:	c9                   	leave  
80102474:	c3                   	ret    
80102475:	00 00                	add    %al,(%eax)
	...

80102478 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102478:	55                   	push   %ebp
80102479:	89 e5                	mov    %esp,%ebp
8010247b:	83 ec 14             	sub    $0x14,%esp
8010247e:	8b 45 08             	mov    0x8(%ebp),%eax
80102481:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102485:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102488:	89 c2                	mov    %eax,%edx
8010248a:	ec                   	in     (%dx),%al
8010248b:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010248e:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80102491:	c9                   	leave  
80102492:	c3                   	ret    

80102493 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102493:	55                   	push   %ebp
80102494:	89 e5                	mov    %esp,%ebp
80102496:	57                   	push   %edi
80102497:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102498:	8b 55 08             	mov    0x8(%ebp),%edx
8010249b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010249e:	8b 45 10             	mov    0x10(%ebp),%eax
801024a1:	89 cb                	mov    %ecx,%ebx
801024a3:	89 df                	mov    %ebx,%edi
801024a5:	89 c1                	mov    %eax,%ecx
801024a7:	fc                   	cld    
801024a8:	f3 6d                	rep insl (%dx),%es:(%edi)
801024aa:	89 c8                	mov    %ecx,%eax
801024ac:	89 fb                	mov    %edi,%ebx
801024ae:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801024b1:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
801024b4:	5b                   	pop    %ebx
801024b5:	5f                   	pop    %edi
801024b6:	5d                   	pop    %ebp
801024b7:	c3                   	ret    

801024b8 <outb>:

static inline void
outb(ushort port, uchar data)
{
801024b8:	55                   	push   %ebp
801024b9:	89 e5                	mov    %esp,%ebp
801024bb:	83 ec 08             	sub    $0x8,%esp
801024be:	8b 45 08             	mov    0x8(%ebp),%eax
801024c1:	8b 55 0c             	mov    0xc(%ebp),%edx
801024c4:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801024c8:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801024cb:	8a 45 f8             	mov    -0x8(%ebp),%al
801024ce:	8b 55 fc             	mov    -0x4(%ebp),%edx
801024d1:	ee                   	out    %al,(%dx)
}
801024d2:	c9                   	leave  
801024d3:	c3                   	ret    

801024d4 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
801024d4:	55                   	push   %ebp
801024d5:	89 e5                	mov    %esp,%ebp
801024d7:	56                   	push   %esi
801024d8:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801024d9:	8b 55 08             	mov    0x8(%ebp),%edx
801024dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801024df:	8b 45 10             	mov    0x10(%ebp),%eax
801024e2:	89 cb                	mov    %ecx,%ebx
801024e4:	89 de                	mov    %ebx,%esi
801024e6:	89 c1                	mov    %eax,%ecx
801024e8:	fc                   	cld    
801024e9:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801024eb:	89 c8                	mov    %ecx,%eax
801024ed:	89 f3                	mov    %esi,%ebx
801024ef:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801024f2:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
801024f5:	5b                   	pop    %ebx
801024f6:	5e                   	pop    %esi
801024f7:	5d                   	pop    %ebp
801024f8:	c3                   	ret    

801024f9 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801024f9:	55                   	push   %ebp
801024fa:	89 e5                	mov    %esp,%ebp
801024fc:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801024ff:	90                   	nop
80102500:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102507:	e8 6c ff ff ff       	call   80102478 <inb>
8010250c:	0f b6 c0             	movzbl %al,%eax
8010250f:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102512:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102515:	25 c0 00 00 00       	and    $0xc0,%eax
8010251a:	83 f8 40             	cmp    $0x40,%eax
8010251d:	75 e1                	jne    80102500 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
8010251f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102523:	74 11                	je     80102536 <idewait+0x3d>
80102525:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102528:	83 e0 21             	and    $0x21,%eax
8010252b:	85 c0                	test   %eax,%eax
8010252d:	74 07                	je     80102536 <idewait+0x3d>
    return -1;
8010252f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102534:	eb 05                	jmp    8010253b <idewait+0x42>
  return 0;
80102536:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010253b:	c9                   	leave  
8010253c:	c3                   	ret    

8010253d <ideinit>:

void
ideinit(void)
{
8010253d:	55                   	push   %ebp
8010253e:	89 e5                	mov    %esp,%ebp
80102540:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
80102543:	c7 44 24 04 fc 86 10 	movl   $0x801086fc,0x4(%esp)
8010254a:	80 
8010254b:	c7 04 24 20 b6 10 80 	movl   $0x8010b620,(%esp)
80102552:	e8 af 29 00 00       	call   80104f06 <initlock>
  picenable(IRQ_IDE);
80102557:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
8010255e:	e8 21 18 00 00       	call   80103d84 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102563:	a1 20 3e 11 80       	mov    0x80113e20,%eax
80102568:	48                   	dec    %eax
80102569:	89 44 24 04          	mov    %eax,0x4(%esp)
8010256d:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102574:	e8 74 04 00 00       	call   801029ed <ioapicenable>
  idewait(0);
80102579:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102580:	e8 74 ff ff ff       	call   801024f9 <idewait>

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102585:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
8010258c:	00 
8010258d:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102594:	e8 1f ff ff ff       	call   801024b8 <outb>
  for(i=0; i<1000; i++){
80102599:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801025a0:	eb 1f                	jmp    801025c1 <ideinit+0x84>
    if(inb(0x1f7) != 0){
801025a2:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801025a9:	e8 ca fe ff ff       	call   80102478 <inb>
801025ae:	84 c0                	test   %al,%al
801025b0:	74 0c                	je     801025be <ideinit+0x81>
      havedisk1 = 1;
801025b2:	c7 05 58 b6 10 80 01 	movl   $0x1,0x8010b658
801025b9:	00 00 00 
      break;
801025bc:	eb 0c                	jmp    801025ca <ideinit+0x8d>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
801025be:	ff 45 f4             	incl   -0xc(%ebp)
801025c1:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801025c8:	7e d8                	jle    801025a2 <ideinit+0x65>
      break;
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801025ca:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
801025d1:	00 
801025d2:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801025d9:	e8 da fe ff ff       	call   801024b8 <outb>
}
801025de:	c9                   	leave  
801025df:	c3                   	ret    

801025e0 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801025e0:	55                   	push   %ebp
801025e1:	89 e5                	mov    %esp,%ebp
801025e3:	83 ec 28             	sub    $0x28,%esp
  if(b == 0)
801025e6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801025ea:	75 0c                	jne    801025f8 <idestart+0x18>
    panic("idestart");
801025ec:	c7 04 24 00 87 10 80 	movl   $0x80108700,(%esp)
801025f3:	e8 5c df ff ff       	call   80100554 <panic>
  if(b->blockno >= FSSIZE)
801025f8:	8b 45 08             	mov    0x8(%ebp),%eax
801025fb:	8b 40 08             	mov    0x8(%eax),%eax
801025fe:	3d e7 03 00 00       	cmp    $0x3e7,%eax
80102603:	76 0c                	jbe    80102611 <idestart+0x31>
    panic("incorrect blockno");
80102605:	c7 04 24 09 87 10 80 	movl   $0x80108709,(%esp)
8010260c:	e8 43 df ff ff       	call   80100554 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102611:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102618:	8b 45 08             	mov    0x8(%ebp),%eax
8010261b:	8b 50 08             	mov    0x8(%eax),%edx
8010261e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102621:	0f af c2             	imul   %edx,%eax
80102624:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
80102627:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
8010262b:	75 07                	jne    80102634 <idestart+0x54>
8010262d:	b8 20 00 00 00       	mov    $0x20,%eax
80102632:	eb 05                	jmp    80102639 <idestart+0x59>
80102634:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102639:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
8010263c:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102640:	75 07                	jne    80102649 <idestart+0x69>
80102642:	b8 30 00 00 00       	mov    $0x30,%eax
80102647:	eb 05                	jmp    8010264e <idestart+0x6e>
80102649:	b8 c5 00 00 00       	mov    $0xc5,%eax
8010264e:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102651:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102655:	7e 0c                	jle    80102663 <idestart+0x83>
80102657:	c7 04 24 00 87 10 80 	movl   $0x80108700,(%esp)
8010265e:	e8 f1 de ff ff       	call   80100554 <panic>

  idewait(0);
80102663:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010266a:	e8 8a fe ff ff       	call   801024f9 <idewait>
  outb(0x3f6, 0);  // generate interrupt
8010266f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102676:	00 
80102677:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
8010267e:	e8 35 fe ff ff       	call   801024b8 <outb>
  outb(0x1f2, sector_per_block);  // number of sectors
80102683:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102686:	0f b6 c0             	movzbl %al,%eax
80102689:	89 44 24 04          	mov    %eax,0x4(%esp)
8010268d:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
80102694:	e8 1f fe ff ff       	call   801024b8 <outb>
  outb(0x1f3, sector & 0xff);
80102699:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010269c:	0f b6 c0             	movzbl %al,%eax
8010269f:	89 44 24 04          	mov    %eax,0x4(%esp)
801026a3:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
801026aa:	e8 09 fe ff ff       	call   801024b8 <outb>
  outb(0x1f4, (sector >> 8) & 0xff);
801026af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801026b2:	c1 f8 08             	sar    $0x8,%eax
801026b5:	0f b6 c0             	movzbl %al,%eax
801026b8:	89 44 24 04          	mov    %eax,0x4(%esp)
801026bc:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
801026c3:	e8 f0 fd ff ff       	call   801024b8 <outb>
  outb(0x1f5, (sector >> 16) & 0xff);
801026c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801026cb:	c1 f8 10             	sar    $0x10,%eax
801026ce:	0f b6 c0             	movzbl %al,%eax
801026d1:	89 44 24 04          	mov    %eax,0x4(%esp)
801026d5:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
801026dc:	e8 d7 fd ff ff       	call   801024b8 <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
801026e1:	8b 45 08             	mov    0x8(%ebp),%eax
801026e4:	8b 40 04             	mov    0x4(%eax),%eax
801026e7:	83 e0 01             	and    $0x1,%eax
801026ea:	c1 e0 04             	shl    $0x4,%eax
801026ed:	88 c2                	mov    %al,%dl
801026ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801026f2:	c1 f8 18             	sar    $0x18,%eax
801026f5:	83 e0 0f             	and    $0xf,%eax
801026f8:	09 d0                	or     %edx,%eax
801026fa:	83 c8 e0             	or     $0xffffffe0,%eax
801026fd:	0f b6 c0             	movzbl %al,%eax
80102700:	89 44 24 04          	mov    %eax,0x4(%esp)
80102704:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
8010270b:	e8 a8 fd ff ff       	call   801024b8 <outb>
  if(b->flags & B_DIRTY){
80102710:	8b 45 08             	mov    0x8(%ebp),%eax
80102713:	8b 00                	mov    (%eax),%eax
80102715:	83 e0 04             	and    $0x4,%eax
80102718:	85 c0                	test   %eax,%eax
8010271a:	74 36                	je     80102752 <idestart+0x172>
    outb(0x1f7, write_cmd);
8010271c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010271f:	0f b6 c0             	movzbl %al,%eax
80102722:	89 44 24 04          	mov    %eax,0x4(%esp)
80102726:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
8010272d:	e8 86 fd ff ff       	call   801024b8 <outb>
    outsl(0x1f0, b->data, BSIZE/4);
80102732:	8b 45 08             	mov    0x8(%ebp),%eax
80102735:	83 c0 5c             	add    $0x5c,%eax
80102738:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
8010273f:	00 
80102740:	89 44 24 04          	mov    %eax,0x4(%esp)
80102744:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
8010274b:	e8 84 fd ff ff       	call   801024d4 <outsl>
80102750:	eb 16                	jmp    80102768 <idestart+0x188>
  } else {
    outb(0x1f7, read_cmd);
80102752:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102755:	0f b6 c0             	movzbl %al,%eax
80102758:	89 44 24 04          	mov    %eax,0x4(%esp)
8010275c:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102763:	e8 50 fd ff ff       	call   801024b8 <outb>
  }
}
80102768:	c9                   	leave  
80102769:	c3                   	ret    

8010276a <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010276a:	55                   	push   %ebp
8010276b:	89 e5                	mov    %esp,%ebp
8010276d:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102770:	c7 04 24 20 b6 10 80 	movl   $0x8010b620,(%esp)
80102777:	e8 ab 27 00 00       	call   80104f27 <acquire>
  if((b = idequeue) == 0){
8010277c:	a1 54 b6 10 80       	mov    0x8010b654,%eax
80102781:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102784:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102788:	75 11                	jne    8010279b <ideintr+0x31>
    release(&idelock);
8010278a:	c7 04 24 20 b6 10 80 	movl   $0x8010b620,(%esp)
80102791:	e8 f8 27 00 00       	call   80104f8e <release>
    // cprintf("spurious IDE interrupt\n");
    return;
80102796:	e9 90 00 00 00       	jmp    8010282b <ideintr+0xc1>
  }
  idequeue = b->qnext;
8010279b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010279e:	8b 40 58             	mov    0x58(%eax),%eax
801027a1:	a3 54 b6 10 80       	mov    %eax,0x8010b654

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
801027a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027a9:	8b 00                	mov    (%eax),%eax
801027ab:	83 e0 04             	and    $0x4,%eax
801027ae:	85 c0                	test   %eax,%eax
801027b0:	75 2e                	jne    801027e0 <ideintr+0x76>
801027b2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801027b9:	e8 3b fd ff ff       	call   801024f9 <idewait>
801027be:	85 c0                	test   %eax,%eax
801027c0:	78 1e                	js     801027e0 <ideintr+0x76>
    insl(0x1f0, b->data, BSIZE/4);
801027c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027c5:	83 c0 5c             	add    $0x5c,%eax
801027c8:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801027cf:	00 
801027d0:	89 44 24 04          	mov    %eax,0x4(%esp)
801027d4:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
801027db:	e8 b3 fc ff ff       	call   80102493 <insl>

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801027e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027e3:	8b 00                	mov    (%eax),%eax
801027e5:	83 c8 02             	or     $0x2,%eax
801027e8:	89 c2                	mov    %eax,%edx
801027ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027ed:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
801027ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027f2:	8b 00                	mov    (%eax),%eax
801027f4:	83 e0 fb             	and    $0xfffffffb,%eax
801027f7:	89 c2                	mov    %eax,%edx
801027f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027fc:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801027fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102801:	89 04 24             	mov    %eax,(%esp)
80102804:	e8 26 24 00 00       	call   80104c2f <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80102809:	a1 54 b6 10 80       	mov    0x8010b654,%eax
8010280e:	85 c0                	test   %eax,%eax
80102810:	74 0d                	je     8010281f <ideintr+0xb5>
    idestart(idequeue);
80102812:	a1 54 b6 10 80       	mov    0x8010b654,%eax
80102817:	89 04 24             	mov    %eax,(%esp)
8010281a:	e8 c1 fd ff ff       	call   801025e0 <idestart>

  release(&idelock);
8010281f:	c7 04 24 20 b6 10 80 	movl   $0x8010b620,(%esp)
80102826:	e8 63 27 00 00       	call   80104f8e <release>
}
8010282b:	c9                   	leave  
8010282c:	c3                   	ret    

8010282d <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010282d:	55                   	push   %ebp
8010282e:	89 e5                	mov    %esp,%ebp
80102830:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80102833:	8b 45 08             	mov    0x8(%ebp),%eax
80102836:	83 c0 0c             	add    $0xc,%eax
80102839:	89 04 24             	mov    %eax,(%esp)
8010283c:	e8 5f 26 00 00       	call   80104ea0 <holdingsleep>
80102841:	85 c0                	test   %eax,%eax
80102843:	75 0c                	jne    80102851 <iderw+0x24>
    panic("iderw: buf not locked");
80102845:	c7 04 24 1b 87 10 80 	movl   $0x8010871b,(%esp)
8010284c:	e8 03 dd ff ff       	call   80100554 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102851:	8b 45 08             	mov    0x8(%ebp),%eax
80102854:	8b 00                	mov    (%eax),%eax
80102856:	83 e0 06             	and    $0x6,%eax
80102859:	83 f8 02             	cmp    $0x2,%eax
8010285c:	75 0c                	jne    8010286a <iderw+0x3d>
    panic("iderw: nothing to do");
8010285e:	c7 04 24 31 87 10 80 	movl   $0x80108731,(%esp)
80102865:	e8 ea dc ff ff       	call   80100554 <panic>
  if(b->dev != 0 && !havedisk1)
8010286a:	8b 45 08             	mov    0x8(%ebp),%eax
8010286d:	8b 40 04             	mov    0x4(%eax),%eax
80102870:	85 c0                	test   %eax,%eax
80102872:	74 15                	je     80102889 <iderw+0x5c>
80102874:	a1 58 b6 10 80       	mov    0x8010b658,%eax
80102879:	85 c0                	test   %eax,%eax
8010287b:	75 0c                	jne    80102889 <iderw+0x5c>
    panic("iderw: ide disk 1 not present");
8010287d:	c7 04 24 46 87 10 80 	movl   $0x80108746,(%esp)
80102884:	e8 cb dc ff ff       	call   80100554 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102889:	c7 04 24 20 b6 10 80 	movl   $0x8010b620,(%esp)
80102890:	e8 92 26 00 00       	call   80104f27 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102895:	8b 45 08             	mov    0x8(%ebp),%eax
80102898:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
8010289f:	c7 45 f4 54 b6 10 80 	movl   $0x8010b654,-0xc(%ebp)
801028a6:	eb 0b                	jmp    801028b3 <iderw+0x86>
801028a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028ab:	8b 00                	mov    (%eax),%eax
801028ad:	83 c0 58             	add    $0x58,%eax
801028b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801028b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028b6:	8b 00                	mov    (%eax),%eax
801028b8:	85 c0                	test   %eax,%eax
801028ba:	75 ec                	jne    801028a8 <iderw+0x7b>
    ;
  *pp = b;
801028bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028bf:	8b 55 08             	mov    0x8(%ebp),%edx
801028c2:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
801028c4:	a1 54 b6 10 80       	mov    0x8010b654,%eax
801028c9:	3b 45 08             	cmp    0x8(%ebp),%eax
801028cc:	75 0d                	jne    801028db <iderw+0xae>
    idestart(b);
801028ce:	8b 45 08             	mov    0x8(%ebp),%eax
801028d1:	89 04 24             	mov    %eax,(%esp)
801028d4:	e8 07 fd ff ff       	call   801025e0 <idestart>

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801028d9:	eb 15                	jmp    801028f0 <iderw+0xc3>
801028db:	eb 13                	jmp    801028f0 <iderw+0xc3>
    sleep(b, &idelock);
801028dd:	c7 44 24 04 20 b6 10 	movl   $0x8010b620,0x4(%esp)
801028e4:	80 
801028e5:	8b 45 08             	mov    0x8(%ebp),%eax
801028e8:	89 04 24             	mov    %eax,(%esp)
801028eb:	e8 66 22 00 00       	call   80104b56 <sleep>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801028f0:	8b 45 08             	mov    0x8(%ebp),%eax
801028f3:	8b 00                	mov    (%eax),%eax
801028f5:	83 e0 06             	and    $0x6,%eax
801028f8:	83 f8 02             	cmp    $0x2,%eax
801028fb:	75 e0                	jne    801028dd <iderw+0xb0>
    sleep(b, &idelock);
  }

  release(&idelock);
801028fd:	c7 04 24 20 b6 10 80 	movl   $0x8010b620,(%esp)
80102904:	e8 85 26 00 00       	call   80104f8e <release>
}
80102909:	c9                   	leave  
8010290a:	c3                   	ret    
	...

8010290c <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
8010290c:	55                   	push   %ebp
8010290d:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010290f:	a1 f4 36 11 80       	mov    0x801136f4,%eax
80102914:	8b 55 08             	mov    0x8(%ebp),%edx
80102917:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102919:	a1 f4 36 11 80       	mov    0x801136f4,%eax
8010291e:	8b 40 10             	mov    0x10(%eax),%eax
}
80102921:	5d                   	pop    %ebp
80102922:	c3                   	ret    

80102923 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102923:	55                   	push   %ebp
80102924:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102926:	a1 f4 36 11 80       	mov    0x801136f4,%eax
8010292b:	8b 55 08             	mov    0x8(%ebp),%edx
8010292e:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102930:	a1 f4 36 11 80       	mov    0x801136f4,%eax
80102935:	8b 55 0c             	mov    0xc(%ebp),%edx
80102938:	89 50 10             	mov    %edx,0x10(%eax)
}
8010293b:	5d                   	pop    %ebp
8010293c:	c3                   	ret    

8010293d <ioapicinit>:

void
ioapicinit(void)
{
8010293d:	55                   	push   %ebp
8010293e:	89 e5                	mov    %esp,%ebp
80102940:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  if(!ismp)
80102943:	a1 24 38 11 80       	mov    0x80113824,%eax
80102948:	85 c0                	test   %eax,%eax
8010294a:	75 05                	jne    80102951 <ioapicinit+0x14>
    return;
8010294c:	e9 9a 00 00 00       	jmp    801029eb <ioapicinit+0xae>

  ioapic = (volatile struct ioapic*)IOAPIC;
80102951:	c7 05 f4 36 11 80 00 	movl   $0xfec00000,0x801136f4
80102958:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
8010295b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102962:	e8 a5 ff ff ff       	call   8010290c <ioapicread>
80102967:	c1 e8 10             	shr    $0x10,%eax
8010296a:	25 ff 00 00 00       	and    $0xff,%eax
8010296f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102972:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102979:	e8 8e ff ff ff       	call   8010290c <ioapicread>
8010297e:	c1 e8 18             	shr    $0x18,%eax
80102981:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102984:	a0 20 38 11 80       	mov    0x80113820,%al
80102989:	0f b6 c0             	movzbl %al,%eax
8010298c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010298f:	74 0c                	je     8010299d <ioapicinit+0x60>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102991:	c7 04 24 64 87 10 80 	movl   $0x80108764,(%esp)
80102998:	e8 24 da ff ff       	call   801003c1 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
8010299d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801029a4:	eb 3d                	jmp    801029e3 <ioapicinit+0xa6>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801029a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029a9:	83 c0 20             	add    $0x20,%eax
801029ac:	0d 00 00 01 00       	or     $0x10000,%eax
801029b1:	89 c2                	mov    %eax,%edx
801029b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029b6:	83 c0 08             	add    $0x8,%eax
801029b9:	01 c0                	add    %eax,%eax
801029bb:	89 54 24 04          	mov    %edx,0x4(%esp)
801029bf:	89 04 24             	mov    %eax,(%esp)
801029c2:	e8 5c ff ff ff       	call   80102923 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
801029c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029ca:	83 c0 08             	add    $0x8,%eax
801029cd:	01 c0                	add    %eax,%eax
801029cf:	40                   	inc    %eax
801029d0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801029d7:	00 
801029d8:	89 04 24             	mov    %eax,(%esp)
801029db:	e8 43 ff ff ff       	call   80102923 <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801029e0:	ff 45 f4             	incl   -0xc(%ebp)
801029e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029e6:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801029e9:	7e bb                	jle    801029a6 <ioapicinit+0x69>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
801029eb:	c9                   	leave  
801029ec:	c3                   	ret    

801029ed <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
801029ed:	55                   	push   %ebp
801029ee:	89 e5                	mov    %esp,%ebp
801029f0:	83 ec 08             	sub    $0x8,%esp
  if(!ismp)
801029f3:	a1 24 38 11 80       	mov    0x80113824,%eax
801029f8:	85 c0                	test   %eax,%eax
801029fa:	75 02                	jne    801029fe <ioapicenable+0x11>
    return;
801029fc:	eb 37                	jmp    80102a35 <ioapicenable+0x48>

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
801029fe:	8b 45 08             	mov    0x8(%ebp),%eax
80102a01:	83 c0 20             	add    $0x20,%eax
80102a04:	89 c2                	mov    %eax,%edx
80102a06:	8b 45 08             	mov    0x8(%ebp),%eax
80102a09:	83 c0 08             	add    $0x8,%eax
80102a0c:	01 c0                	add    %eax,%eax
80102a0e:	89 54 24 04          	mov    %edx,0x4(%esp)
80102a12:	89 04 24             	mov    %eax,(%esp)
80102a15:	e8 09 ff ff ff       	call   80102923 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102a1a:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a1d:	c1 e0 18             	shl    $0x18,%eax
80102a20:	8b 55 08             	mov    0x8(%ebp),%edx
80102a23:	83 c2 08             	add    $0x8,%edx
80102a26:	01 d2                	add    %edx,%edx
80102a28:	42                   	inc    %edx
80102a29:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a2d:	89 14 24             	mov    %edx,(%esp)
80102a30:	e8 ee fe ff ff       	call   80102923 <ioapicwrite>
}
80102a35:	c9                   	leave  
80102a36:	c3                   	ret    
	...

80102a38 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102a38:	55                   	push   %ebp
80102a39:	89 e5                	mov    %esp,%ebp
80102a3b:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80102a3e:	c7 44 24 04 96 87 10 	movl   $0x80108796,0x4(%esp)
80102a45:	80 
80102a46:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
80102a4d:	e8 b4 24 00 00       	call   80104f06 <initlock>
  kmem.use_lock = 0;
80102a52:	c7 05 34 37 11 80 00 	movl   $0x0,0x80113734
80102a59:	00 00 00 
  freerange(vstart, vend);
80102a5c:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a5f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a63:	8b 45 08             	mov    0x8(%ebp),%eax
80102a66:	89 04 24             	mov    %eax,(%esp)
80102a69:	e8 26 00 00 00       	call   80102a94 <freerange>
}
80102a6e:	c9                   	leave  
80102a6f:	c3                   	ret    

80102a70 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102a70:	55                   	push   %ebp
80102a71:	89 e5                	mov    %esp,%ebp
80102a73:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102a76:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a79:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a7d:	8b 45 08             	mov    0x8(%ebp),%eax
80102a80:	89 04 24             	mov    %eax,(%esp)
80102a83:	e8 0c 00 00 00       	call   80102a94 <freerange>
  kmem.use_lock = 1;
80102a88:	c7 05 34 37 11 80 01 	movl   $0x1,0x80113734
80102a8f:	00 00 00 
}
80102a92:	c9                   	leave  
80102a93:	c3                   	ret    

80102a94 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102a94:	55                   	push   %ebp
80102a95:	89 e5                	mov    %esp,%ebp
80102a97:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102a9a:	8b 45 08             	mov    0x8(%ebp),%eax
80102a9d:	05 ff 0f 00 00       	add    $0xfff,%eax
80102aa2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102aa7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102aaa:	eb 12                	jmp    80102abe <freerange+0x2a>
    kfree(p);
80102aac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aaf:	89 04 24             	mov    %eax,(%esp)
80102ab2:	e8 16 00 00 00       	call   80102acd <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102ab7:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ac1:	05 00 10 00 00       	add    $0x1000,%eax
80102ac6:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102ac9:	76 e1                	jbe    80102aac <freerange+0x18>
    kfree(p);
}
80102acb:	c9                   	leave  
80102acc:	c3                   	ret    

80102acd <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102acd:	55                   	push   %ebp
80102ace:	89 e5                	mov    %esp,%ebp
80102ad0:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102ad3:	8b 45 08             	mov    0x8(%ebp),%eax
80102ad6:	25 ff 0f 00 00       	and    $0xfff,%eax
80102adb:	85 c0                	test   %eax,%eax
80102add:	75 18                	jne    80102af7 <kfree+0x2a>
80102adf:	81 7d 08 c8 65 11 80 	cmpl   $0x801165c8,0x8(%ebp)
80102ae6:	72 0f                	jb     80102af7 <kfree+0x2a>
80102ae8:	8b 45 08             	mov    0x8(%ebp),%eax
80102aeb:	05 00 00 00 80       	add    $0x80000000,%eax
80102af0:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102af5:	76 0c                	jbe    80102b03 <kfree+0x36>
    panic("kfree");
80102af7:	c7 04 24 9b 87 10 80 	movl   $0x8010879b,(%esp)
80102afe:	e8 51 da ff ff       	call   80100554 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102b03:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102b0a:	00 
80102b0b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102b12:	00 
80102b13:	8b 45 08             	mov    0x8(%ebp),%eax
80102b16:	89 04 24             	mov    %eax,(%esp)
80102b19:	e8 6c 26 00 00       	call   8010518a <memset>

  if(kmem.use_lock)
80102b1e:	a1 34 37 11 80       	mov    0x80113734,%eax
80102b23:	85 c0                	test   %eax,%eax
80102b25:	74 0c                	je     80102b33 <kfree+0x66>
    acquire(&kmem.lock);
80102b27:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
80102b2e:	e8 f4 23 00 00       	call   80104f27 <acquire>
  r = (struct run*)v;
80102b33:	8b 45 08             	mov    0x8(%ebp),%eax
80102b36:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102b39:	8b 15 38 37 11 80    	mov    0x80113738,%edx
80102b3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b42:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b47:	a3 38 37 11 80       	mov    %eax,0x80113738
  if(kmem.use_lock)
80102b4c:	a1 34 37 11 80       	mov    0x80113734,%eax
80102b51:	85 c0                	test   %eax,%eax
80102b53:	74 0c                	je     80102b61 <kfree+0x94>
    release(&kmem.lock);
80102b55:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
80102b5c:	e8 2d 24 00 00       	call   80104f8e <release>
}
80102b61:	c9                   	leave  
80102b62:	c3                   	ret    

80102b63 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102b63:	55                   	push   %ebp
80102b64:	89 e5                	mov    %esp,%ebp
80102b66:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102b69:	a1 34 37 11 80       	mov    0x80113734,%eax
80102b6e:	85 c0                	test   %eax,%eax
80102b70:	74 0c                	je     80102b7e <kalloc+0x1b>
    acquire(&kmem.lock);
80102b72:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
80102b79:	e8 a9 23 00 00       	call   80104f27 <acquire>
  r = kmem.freelist;
80102b7e:	a1 38 37 11 80       	mov    0x80113738,%eax
80102b83:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102b86:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102b8a:	74 0a                	je     80102b96 <kalloc+0x33>
    kmem.freelist = r->next;
80102b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b8f:	8b 00                	mov    (%eax),%eax
80102b91:	a3 38 37 11 80       	mov    %eax,0x80113738
  if(kmem.use_lock)
80102b96:	a1 34 37 11 80       	mov    0x80113734,%eax
80102b9b:	85 c0                	test   %eax,%eax
80102b9d:	74 0c                	je     80102bab <kalloc+0x48>
    release(&kmem.lock);
80102b9f:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
80102ba6:	e8 e3 23 00 00       	call   80104f8e <release>
  return (char*)r;
80102bab:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102bae:	c9                   	leave  
80102baf:	c3                   	ret    

80102bb0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102bb0:	55                   	push   %ebp
80102bb1:	89 e5                	mov    %esp,%ebp
80102bb3:	83 ec 14             	sub    $0x14,%esp
80102bb6:	8b 45 08             	mov    0x8(%ebp),%eax
80102bb9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102bbd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102bc0:	89 c2                	mov    %eax,%edx
80102bc2:	ec                   	in     (%dx),%al
80102bc3:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102bc6:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80102bc9:	c9                   	leave  
80102bca:	c3                   	ret    

80102bcb <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102bcb:	55                   	push   %ebp
80102bcc:	89 e5                	mov    %esp,%ebp
80102bce:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102bd1:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102bd8:	e8 d3 ff ff ff       	call   80102bb0 <inb>
80102bdd:	0f b6 c0             	movzbl %al,%eax
80102be0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102be3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102be6:	83 e0 01             	and    $0x1,%eax
80102be9:	85 c0                	test   %eax,%eax
80102beb:	75 0a                	jne    80102bf7 <kbdgetc+0x2c>
    return -1;
80102bed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102bf2:	e9 21 01 00 00       	jmp    80102d18 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102bf7:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102bfe:	e8 ad ff ff ff       	call   80102bb0 <inb>
80102c03:	0f b6 c0             	movzbl %al,%eax
80102c06:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102c09:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102c10:	75 17                	jne    80102c29 <kbdgetc+0x5e>
    shift |= E0ESC;
80102c12:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102c17:	83 c8 40             	or     $0x40,%eax
80102c1a:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
    return 0;
80102c1f:	b8 00 00 00 00       	mov    $0x0,%eax
80102c24:	e9 ef 00 00 00       	jmp    80102d18 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102c29:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c2c:	25 80 00 00 00       	and    $0x80,%eax
80102c31:	85 c0                	test   %eax,%eax
80102c33:	74 44                	je     80102c79 <kbdgetc+0xae>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102c35:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102c3a:	83 e0 40             	and    $0x40,%eax
80102c3d:	85 c0                	test   %eax,%eax
80102c3f:	75 08                	jne    80102c49 <kbdgetc+0x7e>
80102c41:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c44:	83 e0 7f             	and    $0x7f,%eax
80102c47:	eb 03                	jmp    80102c4c <kbdgetc+0x81>
80102c49:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c4c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102c4f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c52:	05 20 90 10 80       	add    $0x80109020,%eax
80102c57:	8a 00                	mov    (%eax),%al
80102c59:	83 c8 40             	or     $0x40,%eax
80102c5c:	0f b6 c0             	movzbl %al,%eax
80102c5f:	f7 d0                	not    %eax
80102c61:	89 c2                	mov    %eax,%edx
80102c63:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102c68:	21 d0                	and    %edx,%eax
80102c6a:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
    return 0;
80102c6f:	b8 00 00 00 00       	mov    $0x0,%eax
80102c74:	e9 9f 00 00 00       	jmp    80102d18 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102c79:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102c7e:	83 e0 40             	and    $0x40,%eax
80102c81:	85 c0                	test   %eax,%eax
80102c83:	74 14                	je     80102c99 <kbdgetc+0xce>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102c85:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102c8c:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102c91:	83 e0 bf             	and    $0xffffffbf,%eax
80102c94:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
  }

  shift |= shiftcode[data];
80102c99:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c9c:	05 20 90 10 80       	add    $0x80109020,%eax
80102ca1:	8a 00                	mov    (%eax),%al
80102ca3:	0f b6 d0             	movzbl %al,%edx
80102ca6:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102cab:	09 d0                	or     %edx,%eax
80102cad:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
  shift ^= togglecode[data];
80102cb2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102cb5:	05 20 91 10 80       	add    $0x80109120,%eax
80102cba:	8a 00                	mov    (%eax),%al
80102cbc:	0f b6 d0             	movzbl %al,%edx
80102cbf:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102cc4:	31 d0                	xor    %edx,%eax
80102cc6:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
  c = charcode[shift & (CTL | SHIFT)][data];
80102ccb:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102cd0:	83 e0 03             	and    $0x3,%eax
80102cd3:	8b 14 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%edx
80102cda:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102cdd:	01 d0                	add    %edx,%eax
80102cdf:	8a 00                	mov    (%eax),%al
80102ce1:	0f b6 c0             	movzbl %al,%eax
80102ce4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102ce7:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102cec:	83 e0 08             	and    $0x8,%eax
80102cef:	85 c0                	test   %eax,%eax
80102cf1:	74 22                	je     80102d15 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102cf3:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102cf7:	76 0c                	jbe    80102d05 <kbdgetc+0x13a>
80102cf9:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102cfd:	77 06                	ja     80102d05 <kbdgetc+0x13a>
      c += 'A' - 'a';
80102cff:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102d03:	eb 10                	jmp    80102d15 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102d05:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102d09:	76 0a                	jbe    80102d15 <kbdgetc+0x14a>
80102d0b:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102d0f:	77 04                	ja     80102d15 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102d11:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102d15:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102d18:	c9                   	leave  
80102d19:	c3                   	ret    

80102d1a <kbdintr>:

void
kbdintr(void)
{
80102d1a:	55                   	push   %ebp
80102d1b:	89 e5                	mov    %esp,%ebp
80102d1d:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102d20:	c7 04 24 cb 2b 10 80 	movl   $0x80102bcb,(%esp)
80102d27:	e8 9f da ff ff       	call   801007cb <consoleintr>
}
80102d2c:	c9                   	leave  
80102d2d:	c3                   	ret    
	...

80102d30 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102d30:	55                   	push   %ebp
80102d31:	89 e5                	mov    %esp,%ebp
80102d33:	83 ec 14             	sub    $0x14,%esp
80102d36:	8b 45 08             	mov    0x8(%ebp),%eax
80102d39:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d3d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102d40:	89 c2                	mov    %eax,%edx
80102d42:	ec                   	in     (%dx),%al
80102d43:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102d46:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80102d49:	c9                   	leave  
80102d4a:	c3                   	ret    

80102d4b <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102d4b:	55                   	push   %ebp
80102d4c:	89 e5                	mov    %esp,%ebp
80102d4e:	83 ec 08             	sub    $0x8,%esp
80102d51:	8b 45 08             	mov    0x8(%ebp),%eax
80102d54:	8b 55 0c             	mov    0xc(%ebp),%edx
80102d57:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102d5b:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d5e:	8a 45 f8             	mov    -0x8(%ebp),%al
80102d61:	8b 55 fc             	mov    -0x4(%ebp),%edx
80102d64:	ee                   	out    %al,(%dx)
}
80102d65:	c9                   	leave  
80102d66:	c3                   	ret    

80102d67 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102d67:	55                   	push   %ebp
80102d68:	89 e5                	mov    %esp,%ebp
80102d6a:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102d6d:	9c                   	pushf  
80102d6e:	58                   	pop    %eax
80102d6f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80102d72:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102d75:	c9                   	leave  
80102d76:	c3                   	ret    

80102d77 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102d77:	55                   	push   %ebp
80102d78:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102d7a:	a1 3c 37 11 80       	mov    0x8011373c,%eax
80102d7f:	8b 55 08             	mov    0x8(%ebp),%edx
80102d82:	c1 e2 02             	shl    $0x2,%edx
80102d85:	01 c2                	add    %eax,%edx
80102d87:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d8a:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102d8c:	a1 3c 37 11 80       	mov    0x8011373c,%eax
80102d91:	83 c0 20             	add    $0x20,%eax
80102d94:	8b 00                	mov    (%eax),%eax
}
80102d96:	5d                   	pop    %ebp
80102d97:	c3                   	ret    

80102d98 <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102d98:	55                   	push   %ebp
80102d99:	89 e5                	mov    %esp,%ebp
80102d9b:	83 ec 08             	sub    $0x8,%esp
  if(!lapic)
80102d9e:	a1 3c 37 11 80       	mov    0x8011373c,%eax
80102da3:	85 c0                	test   %eax,%eax
80102da5:	75 05                	jne    80102dac <lapicinit+0x14>
    return;
80102da7:	e9 43 01 00 00       	jmp    80102eef <lapicinit+0x157>

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102dac:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80102db3:	00 
80102db4:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80102dbb:	e8 b7 ff ff ff       	call   80102d77 <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102dc0:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80102dc7:	00 
80102dc8:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80102dcf:	e8 a3 ff ff ff       	call   80102d77 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102dd4:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80102ddb:	00 
80102ddc:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102de3:	e8 8f ff ff ff       	call   80102d77 <lapicw>
  lapicw(TICR, 10000000);
80102de8:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80102def:	00 
80102df0:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
80102df7:	e8 7b ff ff ff       	call   80102d77 <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102dfc:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102e03:	00 
80102e04:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
80102e0b:	e8 67 ff ff ff       	call   80102d77 <lapicw>
  lapicw(LINT1, MASKED);
80102e10:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102e17:	00 
80102e18:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80102e1f:	e8 53 ff ff ff       	call   80102d77 <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102e24:	a1 3c 37 11 80       	mov    0x8011373c,%eax
80102e29:	83 c0 30             	add    $0x30,%eax
80102e2c:	8b 00                	mov    (%eax),%eax
80102e2e:	c1 e8 10             	shr    $0x10,%eax
80102e31:	0f b6 c0             	movzbl %al,%eax
80102e34:	83 f8 03             	cmp    $0x3,%eax
80102e37:	76 14                	jbe    80102e4d <lapicinit+0xb5>
    lapicw(PCINT, MASKED);
80102e39:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102e40:	00 
80102e41:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80102e48:	e8 2a ff ff ff       	call   80102d77 <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102e4d:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80102e54:	00 
80102e55:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80102e5c:	e8 16 ff ff ff       	call   80102d77 <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102e61:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e68:	00 
80102e69:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102e70:	e8 02 ff ff ff       	call   80102d77 <lapicw>
  lapicw(ESR, 0);
80102e75:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e7c:	00 
80102e7d:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102e84:	e8 ee fe ff ff       	call   80102d77 <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102e89:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e90:	00 
80102e91:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102e98:	e8 da fe ff ff       	call   80102d77 <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102e9d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102ea4:	00 
80102ea5:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102eac:	e8 c6 fe ff ff       	call   80102d77 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102eb1:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80102eb8:	00 
80102eb9:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102ec0:	e8 b2 fe ff ff       	call   80102d77 <lapicw>
  while(lapic[ICRLO] & DELIVS)
80102ec5:	90                   	nop
80102ec6:	a1 3c 37 11 80       	mov    0x8011373c,%eax
80102ecb:	05 00 03 00 00       	add    $0x300,%eax
80102ed0:	8b 00                	mov    (%eax),%eax
80102ed2:	25 00 10 00 00       	and    $0x1000,%eax
80102ed7:	85 c0                	test   %eax,%eax
80102ed9:	75 eb                	jne    80102ec6 <lapicinit+0x12e>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102edb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102ee2:	00 
80102ee3:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80102eea:	e8 88 fe ff ff       	call   80102d77 <lapicw>
}
80102eef:	c9                   	leave  
80102ef0:	c3                   	ret    

80102ef1 <cpunum>:

int
cpunum(void)
{
80102ef1:	55                   	push   %ebp
80102ef2:	89 e5                	mov    %esp,%ebp
80102ef4:	83 ec 28             	sub    $0x28,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80102ef7:	e8 6b fe ff ff       	call   80102d67 <readeflags>
80102efc:	25 00 02 00 00       	and    $0x200,%eax
80102f01:	85 c0                	test   %eax,%eax
80102f03:	74 25                	je     80102f2a <cpunum+0x39>
    static int n;
    if(n++ == 0)
80102f05:	a1 60 b6 10 80       	mov    0x8010b660,%eax
80102f0a:	8d 50 01             	lea    0x1(%eax),%edx
80102f0d:	89 15 60 b6 10 80    	mov    %edx,0x8010b660
80102f13:	85 c0                	test   %eax,%eax
80102f15:	75 13                	jne    80102f2a <cpunum+0x39>
      cprintf("cpu called from %x with interrupts enabled\n",
80102f17:	8b 45 04             	mov    0x4(%ebp),%eax
80102f1a:	89 44 24 04          	mov    %eax,0x4(%esp)
80102f1e:	c7 04 24 a4 87 10 80 	movl   $0x801087a4,(%esp)
80102f25:	e8 97 d4 ff ff       	call   801003c1 <cprintf>
        __builtin_return_address(0));
  }

  if (!lapic)
80102f2a:	a1 3c 37 11 80       	mov    0x8011373c,%eax
80102f2f:	85 c0                	test   %eax,%eax
80102f31:	75 07                	jne    80102f3a <cpunum+0x49>
    return 0;
80102f33:	b8 00 00 00 00       	mov    $0x0,%eax
80102f38:	eb 5d                	jmp    80102f97 <cpunum+0xa6>

  apicid = lapic[ID] >> 24;
80102f3a:	a1 3c 37 11 80       	mov    0x8011373c,%eax
80102f3f:	83 c0 20             	add    $0x20,%eax
80102f42:	8b 00                	mov    (%eax),%eax
80102f44:	c1 e8 18             	shr    $0x18,%eax
80102f47:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for (i = 0; i < ncpu; ++i) {
80102f4a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102f51:	eb 2e                	jmp    80102f81 <cpunum+0x90>
    if (cpus[i].apicid == apicid)
80102f53:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f56:	89 d0                	mov    %edx,%eax
80102f58:	c1 e0 02             	shl    $0x2,%eax
80102f5b:	01 d0                	add    %edx,%eax
80102f5d:	01 c0                	add    %eax,%eax
80102f5f:	01 d0                	add    %edx,%eax
80102f61:	89 c1                	mov    %eax,%ecx
80102f63:	c1 e1 04             	shl    $0x4,%ecx
80102f66:	01 c8                	add    %ecx,%eax
80102f68:	01 d0                	add    %edx,%eax
80102f6a:	05 40 38 11 80       	add    $0x80113840,%eax
80102f6f:	8a 00                	mov    (%eax),%al
80102f71:	0f b6 c0             	movzbl %al,%eax
80102f74:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102f77:	75 05                	jne    80102f7e <cpunum+0x8d>
      return i;
80102f79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f7c:	eb 19                	jmp    80102f97 <cpunum+0xa6>

  if (!lapic)
    return 0;

  apicid = lapic[ID] >> 24;
  for (i = 0; i < ncpu; ++i) {
80102f7e:	ff 45 f4             	incl   -0xc(%ebp)
80102f81:	a1 20 3e 11 80       	mov    0x80113e20,%eax
80102f86:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f89:	7c c8                	jl     80102f53 <cpunum+0x62>
    if (cpus[i].apicid == apicid)
      return i;
  }
  panic("unknown apicid\n");
80102f8b:	c7 04 24 d0 87 10 80 	movl   $0x801087d0,(%esp)
80102f92:	e8 bd d5 ff ff       	call   80100554 <panic>
}
80102f97:	c9                   	leave  
80102f98:	c3                   	ret    

80102f99 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102f99:	55                   	push   %ebp
80102f9a:	89 e5                	mov    %esp,%ebp
80102f9c:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
80102f9f:	a1 3c 37 11 80       	mov    0x8011373c,%eax
80102fa4:	85 c0                	test   %eax,%eax
80102fa6:	74 14                	je     80102fbc <lapiceoi+0x23>
    lapicw(EOI, 0);
80102fa8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102faf:	00 
80102fb0:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102fb7:	e8 bb fd ff ff       	call   80102d77 <lapicw>
}
80102fbc:	c9                   	leave  
80102fbd:	c3                   	ret    

80102fbe <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102fbe:	55                   	push   %ebp
80102fbf:	89 e5                	mov    %esp,%ebp
}
80102fc1:	5d                   	pop    %ebp
80102fc2:	c3                   	ret    

80102fc3 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102fc3:	55                   	push   %ebp
80102fc4:	89 e5                	mov    %esp,%ebp
80102fc6:	83 ec 1c             	sub    $0x1c,%esp
80102fc9:	8b 45 08             	mov    0x8(%ebp),%eax
80102fcc:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102fcf:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80102fd6:	00 
80102fd7:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80102fde:	e8 68 fd ff ff       	call   80102d4b <outb>
  outb(CMOS_PORT+1, 0x0A);
80102fe3:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80102fea:	00 
80102feb:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80102ff2:	e8 54 fd ff ff       	call   80102d4b <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102ff7:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102ffe:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103001:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103006:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103009:	8d 50 02             	lea    0x2(%eax),%edx
8010300c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010300f:	c1 e8 04             	shr    $0x4,%eax
80103012:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103015:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103019:	c1 e0 18             	shl    $0x18,%eax
8010301c:	89 44 24 04          	mov    %eax,0x4(%esp)
80103020:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103027:	e8 4b fd ff ff       	call   80102d77 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010302c:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
80103033:	00 
80103034:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
8010303b:	e8 37 fd ff ff       	call   80102d77 <lapicw>
  microdelay(200);
80103040:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103047:	e8 72 ff ff ff       	call   80102fbe <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
8010304c:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
80103053:	00 
80103054:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
8010305b:	e8 17 fd ff ff       	call   80102d77 <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80103060:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80103067:	e8 52 ff ff ff       	call   80102fbe <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010306c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103073:	eb 3f                	jmp    801030b4 <lapicstartap+0xf1>
    lapicw(ICRHI, apicid<<24);
80103075:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103079:	c1 e0 18             	shl    $0x18,%eax
8010307c:	89 44 24 04          	mov    %eax,0x4(%esp)
80103080:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103087:	e8 eb fc ff ff       	call   80102d77 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
8010308c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010308f:	c1 e8 0c             	shr    $0xc,%eax
80103092:	80 cc 06             	or     $0x6,%ah
80103095:	89 44 24 04          	mov    %eax,0x4(%esp)
80103099:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801030a0:	e8 d2 fc ff ff       	call   80102d77 <lapicw>
    microdelay(200);
801030a5:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801030ac:	e8 0d ff ff ff       	call   80102fbe <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801030b1:	ff 45 fc             	incl   -0x4(%ebp)
801030b4:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
801030b8:	7e bb                	jle    80103075 <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
801030ba:	c9                   	leave  
801030bb:	c3                   	ret    

801030bc <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
801030bc:	55                   	push   %ebp
801030bd:	89 e5                	mov    %esp,%ebp
801030bf:	83 ec 08             	sub    $0x8,%esp
  outb(CMOS_PORT,  reg);
801030c2:	8b 45 08             	mov    0x8(%ebp),%eax
801030c5:	0f b6 c0             	movzbl %al,%eax
801030c8:	89 44 24 04          	mov    %eax,0x4(%esp)
801030cc:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
801030d3:	e8 73 fc ff ff       	call   80102d4b <outb>
  microdelay(200);
801030d8:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801030df:	e8 da fe ff ff       	call   80102fbe <microdelay>

  return inb(CMOS_RETURN);
801030e4:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
801030eb:	e8 40 fc ff ff       	call   80102d30 <inb>
801030f0:	0f b6 c0             	movzbl %al,%eax
}
801030f3:	c9                   	leave  
801030f4:	c3                   	ret    

801030f5 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
801030f5:	55                   	push   %ebp
801030f6:	89 e5                	mov    %esp,%ebp
801030f8:	83 ec 04             	sub    $0x4,%esp
  r->second = cmos_read(SECS);
801030fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80103102:	e8 b5 ff ff ff       	call   801030bc <cmos_read>
80103107:	8b 55 08             	mov    0x8(%ebp),%edx
8010310a:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
8010310c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80103113:	e8 a4 ff ff ff       	call   801030bc <cmos_read>
80103118:	8b 55 08             	mov    0x8(%ebp),%edx
8010311b:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
8010311e:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80103125:	e8 92 ff ff ff       	call   801030bc <cmos_read>
8010312a:	8b 55 08             	mov    0x8(%ebp),%edx
8010312d:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80103130:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
80103137:	e8 80 ff ff ff       	call   801030bc <cmos_read>
8010313c:	8b 55 08             	mov    0x8(%ebp),%edx
8010313f:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80103142:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80103149:	e8 6e ff ff ff       	call   801030bc <cmos_read>
8010314e:	8b 55 08             	mov    0x8(%ebp),%edx
80103151:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80103154:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
8010315b:	e8 5c ff ff ff       	call   801030bc <cmos_read>
80103160:	8b 55 08             	mov    0x8(%ebp),%edx
80103163:	89 42 14             	mov    %eax,0x14(%edx)
}
80103166:	c9                   	leave  
80103167:	c3                   	ret    

80103168 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80103168:	55                   	push   %ebp
80103169:	89 e5                	mov    %esp,%ebp
8010316b:	57                   	push   %edi
8010316c:	56                   	push   %esi
8010316d:	53                   	push   %ebx
8010316e:	83 ec 5c             	sub    $0x5c,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80103171:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
80103178:	e8 3f ff ff ff       	call   801030bc <cmos_read>
8010317d:	89 45 e4             	mov    %eax,-0x1c(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80103180:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103183:	83 e0 04             	and    $0x4,%eax
80103186:	85 c0                	test   %eax,%eax
80103188:	0f 94 c0             	sete   %al
8010318b:	0f b6 c0             	movzbl %al,%eax
8010318e:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80103191:	8d 45 c8             	lea    -0x38(%ebp),%eax
80103194:	89 04 24             	mov    %eax,(%esp)
80103197:	e8 59 ff ff ff       	call   801030f5 <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
8010319c:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
801031a3:	e8 14 ff ff ff       	call   801030bc <cmos_read>
801031a8:	25 80 00 00 00       	and    $0x80,%eax
801031ad:	85 c0                	test   %eax,%eax
801031af:	74 02                	je     801031b3 <cmostime+0x4b>
        continue;
801031b1:	eb 36                	jmp    801031e9 <cmostime+0x81>
    fill_rtcdate(&t2);
801031b3:	8d 45 b0             	lea    -0x50(%ebp),%eax
801031b6:	89 04 24             	mov    %eax,(%esp)
801031b9:	e8 37 ff ff ff       	call   801030f5 <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
801031be:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
801031c5:	00 
801031c6:	8d 45 b0             	lea    -0x50(%ebp),%eax
801031c9:	89 44 24 04          	mov    %eax,0x4(%esp)
801031cd:	8d 45 c8             	lea    -0x38(%ebp),%eax
801031d0:	89 04 24             	mov    %eax,(%esp)
801031d3:	e8 29 20 00 00       	call   80105201 <memcmp>
801031d8:	85 c0                	test   %eax,%eax
801031da:	75 0d                	jne    801031e9 <cmostime+0x81>
      break;
801031dc:	90                   	nop
  }

  // convert
  if(bcd) {
801031dd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801031e1:	0f 84 ac 00 00 00    	je     80103293 <cmostime+0x12b>
801031e7:	eb 02                	jmp    801031eb <cmostime+0x83>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
801031e9:	eb a6                	jmp    80103191 <cmostime+0x29>

  // convert
  if(bcd) {
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801031eb:	8b 45 c8             	mov    -0x38(%ebp),%eax
801031ee:	c1 e8 04             	shr    $0x4,%eax
801031f1:	89 c2                	mov    %eax,%edx
801031f3:	89 d0                	mov    %edx,%eax
801031f5:	c1 e0 02             	shl    $0x2,%eax
801031f8:	01 d0                	add    %edx,%eax
801031fa:	01 c0                	add    %eax,%eax
801031fc:	8b 55 c8             	mov    -0x38(%ebp),%edx
801031ff:	83 e2 0f             	and    $0xf,%edx
80103202:	01 d0                	add    %edx,%eax
80103204:	89 45 c8             	mov    %eax,-0x38(%ebp)
    CONV(minute);
80103207:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010320a:	c1 e8 04             	shr    $0x4,%eax
8010320d:	89 c2                	mov    %eax,%edx
8010320f:	89 d0                	mov    %edx,%eax
80103211:	c1 e0 02             	shl    $0x2,%eax
80103214:	01 d0                	add    %edx,%eax
80103216:	01 c0                	add    %eax,%eax
80103218:	8b 55 cc             	mov    -0x34(%ebp),%edx
8010321b:	83 e2 0f             	and    $0xf,%edx
8010321e:	01 d0                	add    %edx,%eax
80103220:	89 45 cc             	mov    %eax,-0x34(%ebp)
    CONV(hour  );
80103223:	8b 45 d0             	mov    -0x30(%ebp),%eax
80103226:	c1 e8 04             	shr    $0x4,%eax
80103229:	89 c2                	mov    %eax,%edx
8010322b:	89 d0                	mov    %edx,%eax
8010322d:	c1 e0 02             	shl    $0x2,%eax
80103230:	01 d0                	add    %edx,%eax
80103232:	01 c0                	add    %eax,%eax
80103234:	8b 55 d0             	mov    -0x30(%ebp),%edx
80103237:	83 e2 0f             	and    $0xf,%edx
8010323a:	01 d0                	add    %edx,%eax
8010323c:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(day   );
8010323f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80103242:	c1 e8 04             	shr    $0x4,%eax
80103245:	89 c2                	mov    %eax,%edx
80103247:	89 d0                	mov    %edx,%eax
80103249:	c1 e0 02             	shl    $0x2,%eax
8010324c:	01 d0                	add    %edx,%eax
8010324e:	01 c0                	add    %eax,%eax
80103250:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80103253:	83 e2 0f             	and    $0xf,%edx
80103256:	01 d0                	add    %edx,%eax
80103258:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(month );
8010325b:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010325e:	c1 e8 04             	shr    $0x4,%eax
80103261:	89 c2                	mov    %eax,%edx
80103263:	89 d0                	mov    %edx,%eax
80103265:	c1 e0 02             	shl    $0x2,%eax
80103268:	01 d0                	add    %edx,%eax
8010326a:	01 c0                	add    %eax,%eax
8010326c:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010326f:	83 e2 0f             	and    $0xf,%edx
80103272:	01 d0                	add    %edx,%eax
80103274:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(year  );
80103277:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010327a:	c1 e8 04             	shr    $0x4,%eax
8010327d:	89 c2                	mov    %eax,%edx
8010327f:	89 d0                	mov    %edx,%eax
80103281:	c1 e0 02             	shl    $0x2,%eax
80103284:	01 d0                	add    %edx,%eax
80103286:	01 c0                	add    %eax,%eax
80103288:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010328b:	83 e2 0f             	and    $0xf,%edx
8010328e:	01 d0                	add    %edx,%eax
80103290:	89 45 dc             	mov    %eax,-0x24(%ebp)
#undef     CONV
  }

  *r = t1;
80103293:	8b 45 08             	mov    0x8(%ebp),%eax
80103296:	89 c2                	mov    %eax,%edx
80103298:	8d 5d c8             	lea    -0x38(%ebp),%ebx
8010329b:	b8 06 00 00 00       	mov    $0x6,%eax
801032a0:	89 d7                	mov    %edx,%edi
801032a2:	89 de                	mov    %ebx,%esi
801032a4:	89 c1                	mov    %eax,%ecx
801032a6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  r->year += 2000;
801032a8:	8b 45 08             	mov    0x8(%ebp),%eax
801032ab:	8b 40 14             	mov    0x14(%eax),%eax
801032ae:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
801032b4:	8b 45 08             	mov    0x8(%ebp),%eax
801032b7:	89 50 14             	mov    %edx,0x14(%eax)
}
801032ba:	83 c4 5c             	add    $0x5c,%esp
801032bd:	5b                   	pop    %ebx
801032be:	5e                   	pop    %esi
801032bf:	5f                   	pop    %edi
801032c0:	5d                   	pop    %ebp
801032c1:	c3                   	ret    
	...

801032c4 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
801032c4:	55                   	push   %ebp
801032c5:	89 e5                	mov    %esp,%ebp
801032c7:	83 ec 38             	sub    $0x38,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
801032ca:	c7 44 24 04 e0 87 10 	movl   $0x801087e0,0x4(%esp)
801032d1:	80 
801032d2:	c7 04 24 40 37 11 80 	movl   $0x80113740,(%esp)
801032d9:	e8 28 1c 00 00       	call   80104f06 <initlock>
  readsb(dev, &sb);
801032de:	8d 45 dc             	lea    -0x24(%ebp),%eax
801032e1:	89 44 24 04          	mov    %eax,0x4(%esp)
801032e5:	8b 45 08             	mov    0x8(%ebp),%eax
801032e8:	89 04 24             	mov    %eax,(%esp)
801032eb:	e8 2c e0 ff ff       	call   8010131c <readsb>
  log.start = sb.logstart;
801032f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032f3:	a3 74 37 11 80       	mov    %eax,0x80113774
  log.size = sb.nlog;
801032f8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032fb:	a3 78 37 11 80       	mov    %eax,0x80113778
  log.dev = dev;
80103300:	8b 45 08             	mov    0x8(%ebp),%eax
80103303:	a3 84 37 11 80       	mov    %eax,0x80113784
  recover_from_log();
80103308:	e8 95 01 00 00       	call   801034a2 <recover_from_log>
}
8010330d:	c9                   	leave  
8010330e:	c3                   	ret    

8010330f <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
8010330f:	55                   	push   %ebp
80103310:	89 e5                	mov    %esp,%ebp
80103312:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103315:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010331c:	e9 89 00 00 00       	jmp    801033aa <install_trans+0x9b>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103321:	8b 15 74 37 11 80    	mov    0x80113774,%edx
80103327:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010332a:	01 d0                	add    %edx,%eax
8010332c:	40                   	inc    %eax
8010332d:	89 c2                	mov    %eax,%edx
8010332f:	a1 84 37 11 80       	mov    0x80113784,%eax
80103334:	89 54 24 04          	mov    %edx,0x4(%esp)
80103338:	89 04 24             	mov    %eax,(%esp)
8010333b:	e8 75 ce ff ff       	call   801001b5 <bread>
80103340:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103343:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103346:	83 c0 10             	add    $0x10,%eax
80103349:	8b 04 85 4c 37 11 80 	mov    -0x7feec8b4(,%eax,4),%eax
80103350:	89 c2                	mov    %eax,%edx
80103352:	a1 84 37 11 80       	mov    0x80113784,%eax
80103357:	89 54 24 04          	mov    %edx,0x4(%esp)
8010335b:	89 04 24             	mov    %eax,(%esp)
8010335e:	e8 52 ce ff ff       	call   801001b5 <bread>
80103363:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103366:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103369:	8d 50 5c             	lea    0x5c(%eax),%edx
8010336c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010336f:	83 c0 5c             	add    $0x5c,%eax
80103372:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103379:	00 
8010337a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010337e:	89 04 24             	mov    %eax,(%esp)
80103381:	e8 cd 1e 00 00       	call   80105253 <memmove>
    bwrite(dbuf);  // write dst to disk
80103386:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103389:	89 04 24             	mov    %eax,(%esp)
8010338c:	e8 5b ce ff ff       	call   801001ec <bwrite>
    brelse(lbuf);
80103391:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103394:	89 04 24             	mov    %eax,(%esp)
80103397:	e8 90 ce ff ff       	call   8010022c <brelse>
    brelse(dbuf);
8010339c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010339f:	89 04 24             	mov    %eax,(%esp)
801033a2:	e8 85 ce ff ff       	call   8010022c <brelse>
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801033a7:	ff 45 f4             	incl   -0xc(%ebp)
801033aa:	a1 88 37 11 80       	mov    0x80113788,%eax
801033af:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801033b2:	0f 8f 69 ff ff ff    	jg     80103321 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf);
    brelse(dbuf);
  }
}
801033b8:	c9                   	leave  
801033b9:	c3                   	ret    

801033ba <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801033ba:	55                   	push   %ebp
801033bb:	89 e5                	mov    %esp,%ebp
801033bd:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
801033c0:	a1 74 37 11 80       	mov    0x80113774,%eax
801033c5:	89 c2                	mov    %eax,%edx
801033c7:	a1 84 37 11 80       	mov    0x80113784,%eax
801033cc:	89 54 24 04          	mov    %edx,0x4(%esp)
801033d0:	89 04 24             	mov    %eax,(%esp)
801033d3:	e8 dd cd ff ff       	call   801001b5 <bread>
801033d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
801033db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033de:	83 c0 5c             	add    $0x5c,%eax
801033e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
801033e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033e7:	8b 00                	mov    (%eax),%eax
801033e9:	a3 88 37 11 80       	mov    %eax,0x80113788
  for (i = 0; i < log.lh.n; i++) {
801033ee:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801033f5:	eb 1a                	jmp    80103411 <read_head+0x57>
    log.lh.block[i] = lh->block[i];
801033f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
801033fd:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103401:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103404:	83 c2 10             	add    $0x10,%edx
80103407:	89 04 95 4c 37 11 80 	mov    %eax,-0x7feec8b4(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
8010340e:	ff 45 f4             	incl   -0xc(%ebp)
80103411:	a1 88 37 11 80       	mov    0x80113788,%eax
80103416:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103419:	7f dc                	jg     801033f7 <read_head+0x3d>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
8010341b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010341e:	89 04 24             	mov    %eax,(%esp)
80103421:	e8 06 ce ff ff       	call   8010022c <brelse>
}
80103426:	c9                   	leave  
80103427:	c3                   	ret    

80103428 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103428:	55                   	push   %ebp
80103429:	89 e5                	mov    %esp,%ebp
8010342b:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
8010342e:	a1 74 37 11 80       	mov    0x80113774,%eax
80103433:	89 c2                	mov    %eax,%edx
80103435:	a1 84 37 11 80       	mov    0x80113784,%eax
8010343a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010343e:	89 04 24             	mov    %eax,(%esp)
80103441:	e8 6f cd ff ff       	call   801001b5 <bread>
80103446:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103449:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010344c:	83 c0 5c             	add    $0x5c,%eax
8010344f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103452:	8b 15 88 37 11 80    	mov    0x80113788,%edx
80103458:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010345b:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
8010345d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103464:	eb 1a                	jmp    80103480 <write_head+0x58>
    hb->block[i] = log.lh.block[i];
80103466:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103469:	83 c0 10             	add    $0x10,%eax
8010346c:	8b 0c 85 4c 37 11 80 	mov    -0x7feec8b4(,%eax,4),%ecx
80103473:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103476:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103479:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
8010347d:	ff 45 f4             	incl   -0xc(%ebp)
80103480:	a1 88 37 11 80       	mov    0x80113788,%eax
80103485:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103488:	7f dc                	jg     80103466 <write_head+0x3e>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
8010348a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010348d:	89 04 24             	mov    %eax,(%esp)
80103490:	e8 57 cd ff ff       	call   801001ec <bwrite>
  brelse(buf);
80103495:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103498:	89 04 24             	mov    %eax,(%esp)
8010349b:	e8 8c cd ff ff       	call   8010022c <brelse>
}
801034a0:	c9                   	leave  
801034a1:	c3                   	ret    

801034a2 <recover_from_log>:

static void
recover_from_log(void)
{
801034a2:	55                   	push   %ebp
801034a3:	89 e5                	mov    %esp,%ebp
801034a5:	83 ec 08             	sub    $0x8,%esp
  read_head();
801034a8:	e8 0d ff ff ff       	call   801033ba <read_head>
  install_trans(); // if committed, copy from log to disk
801034ad:	e8 5d fe ff ff       	call   8010330f <install_trans>
  log.lh.n = 0;
801034b2:	c7 05 88 37 11 80 00 	movl   $0x0,0x80113788
801034b9:	00 00 00 
  write_head(); // clear the log
801034bc:	e8 67 ff ff ff       	call   80103428 <write_head>
}
801034c1:	c9                   	leave  
801034c2:	c3                   	ret    

801034c3 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
801034c3:	55                   	push   %ebp
801034c4:	89 e5                	mov    %esp,%ebp
801034c6:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
801034c9:	c7 04 24 40 37 11 80 	movl   $0x80113740,(%esp)
801034d0:	e8 52 1a 00 00       	call   80104f27 <acquire>
  while(1){
    if(log.committing){
801034d5:	a1 80 37 11 80       	mov    0x80113780,%eax
801034da:	85 c0                	test   %eax,%eax
801034dc:	74 16                	je     801034f4 <begin_op+0x31>
      sleep(&log, &log.lock);
801034de:	c7 44 24 04 40 37 11 	movl   $0x80113740,0x4(%esp)
801034e5:	80 
801034e6:	c7 04 24 40 37 11 80 	movl   $0x80113740,(%esp)
801034ed:	e8 64 16 00 00       	call   80104b56 <sleep>
801034f2:	eb 4d                	jmp    80103541 <begin_op+0x7e>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801034f4:	8b 15 88 37 11 80    	mov    0x80113788,%edx
801034fa:	a1 7c 37 11 80       	mov    0x8011377c,%eax
801034ff:	8d 48 01             	lea    0x1(%eax),%ecx
80103502:	89 c8                	mov    %ecx,%eax
80103504:	c1 e0 02             	shl    $0x2,%eax
80103507:	01 c8                	add    %ecx,%eax
80103509:	01 c0                	add    %eax,%eax
8010350b:	01 d0                	add    %edx,%eax
8010350d:	83 f8 1e             	cmp    $0x1e,%eax
80103510:	7e 16                	jle    80103528 <begin_op+0x65>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103512:	c7 44 24 04 40 37 11 	movl   $0x80113740,0x4(%esp)
80103519:	80 
8010351a:	c7 04 24 40 37 11 80 	movl   $0x80113740,(%esp)
80103521:	e8 30 16 00 00       	call   80104b56 <sleep>
80103526:	eb 19                	jmp    80103541 <begin_op+0x7e>
    } else {
      log.outstanding += 1;
80103528:	a1 7c 37 11 80       	mov    0x8011377c,%eax
8010352d:	40                   	inc    %eax
8010352e:	a3 7c 37 11 80       	mov    %eax,0x8011377c
      release(&log.lock);
80103533:	c7 04 24 40 37 11 80 	movl   $0x80113740,(%esp)
8010353a:	e8 4f 1a 00 00       	call   80104f8e <release>
      break;
8010353f:	eb 02                	jmp    80103543 <begin_op+0x80>
    }
  }
80103541:	eb 92                	jmp    801034d5 <begin_op+0x12>
}
80103543:	c9                   	leave  
80103544:	c3                   	ret    

80103545 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103545:	55                   	push   %ebp
80103546:	89 e5                	mov    %esp,%ebp
80103548:	83 ec 28             	sub    $0x28,%esp
  int do_commit = 0;
8010354b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103552:	c7 04 24 40 37 11 80 	movl   $0x80113740,(%esp)
80103559:	e8 c9 19 00 00       	call   80104f27 <acquire>
  log.outstanding -= 1;
8010355e:	a1 7c 37 11 80       	mov    0x8011377c,%eax
80103563:	48                   	dec    %eax
80103564:	a3 7c 37 11 80       	mov    %eax,0x8011377c
  if(log.committing)
80103569:	a1 80 37 11 80       	mov    0x80113780,%eax
8010356e:	85 c0                	test   %eax,%eax
80103570:	74 0c                	je     8010357e <end_op+0x39>
    panic("log.committing");
80103572:	c7 04 24 e4 87 10 80 	movl   $0x801087e4,(%esp)
80103579:	e8 d6 cf ff ff       	call   80100554 <panic>
  if(log.outstanding == 0){
8010357e:	a1 7c 37 11 80       	mov    0x8011377c,%eax
80103583:	85 c0                	test   %eax,%eax
80103585:	75 13                	jne    8010359a <end_op+0x55>
    do_commit = 1;
80103587:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
8010358e:	c7 05 80 37 11 80 01 	movl   $0x1,0x80113780
80103595:	00 00 00 
80103598:	eb 0c                	jmp    801035a6 <end_op+0x61>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
8010359a:	c7 04 24 40 37 11 80 	movl   $0x80113740,(%esp)
801035a1:	e8 89 16 00 00       	call   80104c2f <wakeup>
  }
  release(&log.lock);
801035a6:	c7 04 24 40 37 11 80 	movl   $0x80113740,(%esp)
801035ad:	e8 dc 19 00 00       	call   80104f8e <release>

  if(do_commit){
801035b2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801035b6:	74 33                	je     801035eb <end_op+0xa6>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
801035b8:	e8 db 00 00 00       	call   80103698 <commit>
    acquire(&log.lock);
801035bd:	c7 04 24 40 37 11 80 	movl   $0x80113740,(%esp)
801035c4:	e8 5e 19 00 00       	call   80104f27 <acquire>
    log.committing = 0;
801035c9:	c7 05 80 37 11 80 00 	movl   $0x0,0x80113780
801035d0:	00 00 00 
    wakeup(&log);
801035d3:	c7 04 24 40 37 11 80 	movl   $0x80113740,(%esp)
801035da:	e8 50 16 00 00       	call   80104c2f <wakeup>
    release(&log.lock);
801035df:	c7 04 24 40 37 11 80 	movl   $0x80113740,(%esp)
801035e6:	e8 a3 19 00 00       	call   80104f8e <release>
  }
}
801035eb:	c9                   	leave  
801035ec:	c3                   	ret    

801035ed <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
801035ed:	55                   	push   %ebp
801035ee:	89 e5                	mov    %esp,%ebp
801035f0:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801035f3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801035fa:	e9 89 00 00 00       	jmp    80103688 <write_log+0x9b>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801035ff:	8b 15 74 37 11 80    	mov    0x80113774,%edx
80103605:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103608:	01 d0                	add    %edx,%eax
8010360a:	40                   	inc    %eax
8010360b:	89 c2                	mov    %eax,%edx
8010360d:	a1 84 37 11 80       	mov    0x80113784,%eax
80103612:	89 54 24 04          	mov    %edx,0x4(%esp)
80103616:	89 04 24             	mov    %eax,(%esp)
80103619:	e8 97 cb ff ff       	call   801001b5 <bread>
8010361e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103621:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103624:	83 c0 10             	add    $0x10,%eax
80103627:	8b 04 85 4c 37 11 80 	mov    -0x7feec8b4(,%eax,4),%eax
8010362e:	89 c2                	mov    %eax,%edx
80103630:	a1 84 37 11 80       	mov    0x80113784,%eax
80103635:	89 54 24 04          	mov    %edx,0x4(%esp)
80103639:	89 04 24             	mov    %eax,(%esp)
8010363c:	e8 74 cb ff ff       	call   801001b5 <bread>
80103641:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103644:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103647:	8d 50 5c             	lea    0x5c(%eax),%edx
8010364a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010364d:	83 c0 5c             	add    $0x5c,%eax
80103650:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103657:	00 
80103658:	89 54 24 04          	mov    %edx,0x4(%esp)
8010365c:	89 04 24             	mov    %eax,(%esp)
8010365f:	e8 ef 1b 00 00       	call   80105253 <memmove>
    bwrite(to);  // write the log
80103664:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103667:	89 04 24             	mov    %eax,(%esp)
8010366a:	e8 7d cb ff ff       	call   801001ec <bwrite>
    brelse(from);
8010366f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103672:	89 04 24             	mov    %eax,(%esp)
80103675:	e8 b2 cb ff ff       	call   8010022c <brelse>
    brelse(to);
8010367a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010367d:	89 04 24             	mov    %eax,(%esp)
80103680:	e8 a7 cb ff ff       	call   8010022c <brelse>
static void
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103685:	ff 45 f4             	incl   -0xc(%ebp)
80103688:	a1 88 37 11 80       	mov    0x80113788,%eax
8010368d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103690:	0f 8f 69 ff ff ff    	jg     801035ff <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from);
    brelse(to);
  }
}
80103696:	c9                   	leave  
80103697:	c3                   	ret    

80103698 <commit>:

static void
commit()
{
80103698:	55                   	push   %ebp
80103699:	89 e5                	mov    %esp,%ebp
8010369b:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010369e:	a1 88 37 11 80       	mov    0x80113788,%eax
801036a3:	85 c0                	test   %eax,%eax
801036a5:	7e 1e                	jle    801036c5 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
801036a7:	e8 41 ff ff ff       	call   801035ed <write_log>
    write_head();    // Write header to disk -- the real commit
801036ac:	e8 77 fd ff ff       	call   80103428 <write_head>
    install_trans(); // Now install writes to home locations
801036b1:	e8 59 fc ff ff       	call   8010330f <install_trans>
    log.lh.n = 0;
801036b6:	c7 05 88 37 11 80 00 	movl   $0x0,0x80113788
801036bd:	00 00 00 
    write_head();    // Erase the transaction from the log
801036c0:	e8 63 fd ff ff       	call   80103428 <write_head>
  }
}
801036c5:	c9                   	leave  
801036c6:	c3                   	ret    

801036c7 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801036c7:	55                   	push   %ebp
801036c8:	89 e5                	mov    %esp,%ebp
801036ca:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801036cd:	a1 88 37 11 80       	mov    0x80113788,%eax
801036d2:	83 f8 1d             	cmp    $0x1d,%eax
801036d5:	7f 10                	jg     801036e7 <log_write+0x20>
801036d7:	a1 88 37 11 80       	mov    0x80113788,%eax
801036dc:	8b 15 78 37 11 80    	mov    0x80113778,%edx
801036e2:	4a                   	dec    %edx
801036e3:	39 d0                	cmp    %edx,%eax
801036e5:	7c 0c                	jl     801036f3 <log_write+0x2c>
    panic("too big a transaction");
801036e7:	c7 04 24 f3 87 10 80 	movl   $0x801087f3,(%esp)
801036ee:	e8 61 ce ff ff       	call   80100554 <panic>
  if (log.outstanding < 1)
801036f3:	a1 7c 37 11 80       	mov    0x8011377c,%eax
801036f8:	85 c0                	test   %eax,%eax
801036fa:	7f 0c                	jg     80103708 <log_write+0x41>
    panic("log_write outside of trans");
801036fc:	c7 04 24 09 88 10 80 	movl   $0x80108809,(%esp)
80103703:	e8 4c ce ff ff       	call   80100554 <panic>

  acquire(&log.lock);
80103708:	c7 04 24 40 37 11 80 	movl   $0x80113740,(%esp)
8010370f:	e8 13 18 00 00       	call   80104f27 <acquire>
  for (i = 0; i < log.lh.n; i++) {
80103714:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010371b:	eb 1e                	jmp    8010373b <log_write+0x74>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
8010371d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103720:	83 c0 10             	add    $0x10,%eax
80103723:	8b 04 85 4c 37 11 80 	mov    -0x7feec8b4(,%eax,4),%eax
8010372a:	89 c2                	mov    %eax,%edx
8010372c:	8b 45 08             	mov    0x8(%ebp),%eax
8010372f:	8b 40 08             	mov    0x8(%eax),%eax
80103732:	39 c2                	cmp    %eax,%edx
80103734:	75 02                	jne    80103738 <log_write+0x71>
      break;
80103736:	eb 0d                	jmp    80103745 <log_write+0x7e>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
80103738:	ff 45 f4             	incl   -0xc(%ebp)
8010373b:	a1 88 37 11 80       	mov    0x80113788,%eax
80103740:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103743:	7f d8                	jg     8010371d <log_write+0x56>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
  }
  log.lh.block[i] = b->blockno;
80103745:	8b 45 08             	mov    0x8(%ebp),%eax
80103748:	8b 40 08             	mov    0x8(%eax),%eax
8010374b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010374e:	83 c2 10             	add    $0x10,%edx
80103751:	89 04 95 4c 37 11 80 	mov    %eax,-0x7feec8b4(,%edx,4)
  if (i == log.lh.n)
80103758:	a1 88 37 11 80       	mov    0x80113788,%eax
8010375d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103760:	75 0b                	jne    8010376d <log_write+0xa6>
    log.lh.n++;
80103762:	a1 88 37 11 80       	mov    0x80113788,%eax
80103767:	40                   	inc    %eax
80103768:	a3 88 37 11 80       	mov    %eax,0x80113788
  b->flags |= B_DIRTY; // prevent eviction
8010376d:	8b 45 08             	mov    0x8(%ebp),%eax
80103770:	8b 00                	mov    (%eax),%eax
80103772:	83 c8 04             	or     $0x4,%eax
80103775:	89 c2                	mov    %eax,%edx
80103777:	8b 45 08             	mov    0x8(%ebp),%eax
8010377a:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
8010377c:	c7 04 24 40 37 11 80 	movl   $0x80113740,(%esp)
80103783:	e8 06 18 00 00       	call   80104f8e <release>
}
80103788:	c9                   	leave  
80103789:	c3                   	ret    
	...

8010378c <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010378c:	55                   	push   %ebp
8010378d:	89 e5                	mov    %esp,%ebp
8010378f:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103792:	8b 55 08             	mov    0x8(%ebp),%edx
80103795:	8b 45 0c             	mov    0xc(%ebp),%eax
80103798:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010379b:	f0 87 02             	lock xchg %eax,(%edx)
8010379e:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801037a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801037a4:	c9                   	leave  
801037a5:	c3                   	ret    

801037a6 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801037a6:	55                   	push   %ebp
801037a7:	89 e5                	mov    %esp,%ebp
801037a9:	83 e4 f0             	and    $0xfffffff0,%esp
801037ac:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801037af:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
801037b6:	80 
801037b7:	c7 04 24 c8 65 11 80 	movl   $0x801165c8,(%esp)
801037be:	e8 75 f2 ff ff       	call   80102a38 <kinit1>
  kvmalloc();      // kernel page table
801037c3:	e8 b3 45 00 00       	call   80107d7b <kvmalloc>
  mpinit();        // detect other processors
801037c8:	e8 00 04 00 00       	call   80103bcd <mpinit>
  lapicinit();     // interrupt controller
801037cd:	e8 c6 f5 ff ff       	call   80102d98 <lapicinit>
  seginit();       // segment descriptors
801037d2:	e8 80 3f 00 00       	call   80107757 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpunum());
801037d7:	e8 15 f7 ff ff       	call   80102ef1 <cpunum>
801037dc:	89 44 24 04          	mov    %eax,0x4(%esp)
801037e0:	c7 04 24 24 88 10 80 	movl   $0x80108824,(%esp)
801037e7:	e8 d5 cb ff ff       	call   801003c1 <cprintf>
  picinit();       // another interrupt controller
801037ec:	e8 c0 05 00 00       	call   80103db1 <picinit>
  ioapicinit();    // another interrupt controller
801037f1:	e8 47 f1 ff ff       	call   8010293d <ioapicinit>
  consoleinit();   // console hardware
801037f6:	e8 a8 d2 ff ff       	call   80100aa3 <consoleinit>
  uartinit();      // serial port
801037fb:	e8 c3 32 00 00       	call   80106ac3 <uartinit>
  pinit();         // process table
80103800:	e8 f9 0a 00 00       	call   801042fe <pinit>
  tvinit();        // trap vectors
80103805:	e8 a2 2e 00 00       	call   801066ac <tvinit>
  binit();         // buffer cache
8010380a:	e8 25 c8 ff ff       	call   80100034 <binit>
  fileinit();      // file table
8010380f:	e8 2c d7 ff ff       	call   80100f40 <fileinit>
  ideinit();       // disk
80103814:	e8 24 ed ff ff       	call   8010253d <ideinit>
  if(!ismp)
80103819:	a1 24 38 11 80       	mov    0x80113824,%eax
8010381e:	85 c0                	test   %eax,%eax
80103820:	75 05                	jne    80103827 <main+0x81>
    timerinit();   // uniprocessor timer
80103822:	e8 d1 2d 00 00       	call   801065f8 <timerinit>
  startothers();   // start other processors
80103827:	e8 78 00 00 00       	call   801038a4 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
8010382c:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
80103833:	8e 
80103834:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
8010383b:	e8 30 f2 ff ff       	call   80102a70 <kinit2>
  userinit();      // first user process
80103840:	e8 d4 0b 00 00       	call   80104419 <userinit>
  mpmain();        // finish this processor's setup
80103845:	e8 1a 00 00 00       	call   80103864 <mpmain>

8010384a <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
8010384a:	55                   	push   %ebp
8010384b:	89 e5                	mov    %esp,%ebp
8010384d:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103850:	e8 3d 45 00 00       	call   80107d92 <switchkvm>
  seginit();
80103855:	e8 fd 3e 00 00       	call   80107757 <seginit>
  lapicinit();
8010385a:	e8 39 f5 ff ff       	call   80102d98 <lapicinit>
  mpmain();
8010385f:	e8 00 00 00 00       	call   80103864 <mpmain>

80103864 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103864:	55                   	push   %ebp
80103865:	89 e5                	mov    %esp,%ebp
80103867:	83 ec 18             	sub    $0x18,%esp
  cprintf("cpu%d: starting\n", cpunum());
8010386a:	e8 82 f6 ff ff       	call   80102ef1 <cpunum>
8010386f:	89 44 24 04          	mov    %eax,0x4(%esp)
80103873:	c7 04 24 3b 88 10 80 	movl   $0x8010883b,(%esp)
8010387a:	e8 42 cb ff ff       	call   801003c1 <cprintf>
  idtinit();       // load idt register
8010387f:	e8 85 2f 00 00       	call   80106809 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103884:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010388a:	05 a8 00 00 00       	add    $0xa8,%eax
8010388f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80103896:	00 
80103897:	89 04 24             	mov    %eax,(%esp)
8010389a:	e8 ed fe ff ff       	call   8010378c <xchg>
  scheduler();     // start running processes
8010389f:	e8 fa 10 00 00       	call   8010499e <scheduler>

801038a4 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801038a4:	55                   	push   %ebp
801038a5:	89 e5                	mov    %esp,%ebp
801038a7:	83 ec 28             	sub    $0x28,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
801038aa:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801038b1:	b8 8a 00 00 00       	mov    $0x8a,%eax
801038b6:	89 44 24 08          	mov    %eax,0x8(%esp)
801038ba:	c7 44 24 04 2c b5 10 	movl   $0x8010b52c,0x4(%esp)
801038c1:	80 
801038c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038c5:	89 04 24             	mov    %eax,(%esp)
801038c8:	e8 86 19 00 00       	call   80105253 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
801038cd:	c7 45 f4 40 38 11 80 	movl   $0x80113840,-0xc(%ebp)
801038d4:	e9 90 00 00 00       	jmp    80103969 <startothers+0xc5>
    if(c == cpus+cpunum())  // We've started already.
801038d9:	e8 13 f6 ff ff       	call   80102ef1 <cpunum>
801038de:	89 c2                	mov    %eax,%edx
801038e0:	89 d0                	mov    %edx,%eax
801038e2:	c1 e0 02             	shl    $0x2,%eax
801038e5:	01 d0                	add    %edx,%eax
801038e7:	01 c0                	add    %eax,%eax
801038e9:	01 d0                	add    %edx,%eax
801038eb:	89 c1                	mov    %eax,%ecx
801038ed:	c1 e1 04             	shl    $0x4,%ecx
801038f0:	01 c8                	add    %ecx,%eax
801038f2:	01 d0                	add    %edx,%eax
801038f4:	05 40 38 11 80       	add    $0x80113840,%eax
801038f9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801038fc:	75 02                	jne    80103900 <startothers+0x5c>
      continue;
801038fe:	eb 62                	jmp    80103962 <startothers+0xbe>

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103900:	e8 5e f2 ff ff       	call   80102b63 <kalloc>
80103905:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103908:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010390b:	83 e8 04             	sub    $0x4,%eax
8010390e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103911:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103917:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103919:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010391c:	83 e8 08             	sub    $0x8,%eax
8010391f:	c7 00 4a 38 10 80    	movl   $0x8010384a,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103925:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103928:	8d 50 f4             	lea    -0xc(%eax),%edx
8010392b:	b8 00 a0 10 80       	mov    $0x8010a000,%eax
80103930:	05 00 00 00 80       	add    $0x80000000,%eax
80103935:	89 02                	mov    %eax,(%edx)

    lapicstartap(c->apicid, V2P(code));
80103937:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010393a:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103940:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103943:	8a 00                	mov    (%eax),%al
80103945:	0f b6 c0             	movzbl %al,%eax
80103948:	89 54 24 04          	mov    %edx,0x4(%esp)
8010394c:	89 04 24             	mov    %eax,(%esp)
8010394f:	e8 6f f6 ff ff       	call   80102fc3 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103954:	90                   	nop
80103955:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103958:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010395e:	85 c0                	test   %eax,%eax
80103960:	74 f3                	je     80103955 <startothers+0xb1>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103962:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103969:	a1 20 3e 11 80       	mov    0x80113e20,%eax
8010396e:	89 c2                	mov    %eax,%edx
80103970:	89 d0                	mov    %edx,%eax
80103972:	c1 e0 02             	shl    $0x2,%eax
80103975:	01 d0                	add    %edx,%eax
80103977:	01 c0                	add    %eax,%eax
80103979:	01 d0                	add    %edx,%eax
8010397b:	89 c1                	mov    %eax,%ecx
8010397d:	c1 e1 04             	shl    $0x4,%ecx
80103980:	01 c8                	add    %ecx,%eax
80103982:	01 d0                	add    %edx,%eax
80103984:	05 40 38 11 80       	add    $0x80113840,%eax
80103989:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010398c:	0f 87 47 ff ff ff    	ja     801038d9 <startothers+0x35>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103992:	c9                   	leave  
80103993:	c3                   	ret    

80103994 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103994:	55                   	push   %ebp
80103995:	89 e5                	mov    %esp,%ebp
80103997:	83 ec 14             	sub    $0x14,%esp
8010399a:	8b 45 08             	mov    0x8(%ebp),%eax
8010399d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801039a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801039a4:	89 c2                	mov    %eax,%edx
801039a6:	ec                   	in     (%dx),%al
801039a7:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801039aa:	8a 45 ff             	mov    -0x1(%ebp),%al
}
801039ad:	c9                   	leave  
801039ae:	c3                   	ret    

801039af <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801039af:	55                   	push   %ebp
801039b0:	89 e5                	mov    %esp,%ebp
801039b2:	83 ec 08             	sub    $0x8,%esp
801039b5:	8b 45 08             	mov    0x8(%ebp),%eax
801039b8:	8b 55 0c             	mov    0xc(%ebp),%edx
801039bb:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801039bf:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801039c2:	8a 45 f8             	mov    -0x8(%ebp),%al
801039c5:	8b 55 fc             	mov    -0x4(%ebp),%edx
801039c8:	ee                   	out    %al,(%dx)
}
801039c9:	c9                   	leave  
801039ca:	c3                   	ret    

801039cb <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
801039cb:	55                   	push   %ebp
801039cc:	89 e5                	mov    %esp,%ebp
801039ce:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
801039d1:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
801039d8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801039df:	eb 13                	jmp    801039f4 <sum+0x29>
    sum += addr[i];
801039e1:	8b 55 fc             	mov    -0x4(%ebp),%edx
801039e4:	8b 45 08             	mov    0x8(%ebp),%eax
801039e7:	01 d0                	add    %edx,%eax
801039e9:	8a 00                	mov    (%eax),%al
801039eb:	0f b6 c0             	movzbl %al,%eax
801039ee:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
801039f1:	ff 45 fc             	incl   -0x4(%ebp)
801039f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801039f7:	3b 45 0c             	cmp    0xc(%ebp),%eax
801039fa:	7c e5                	jl     801039e1 <sum+0x16>
    sum += addr[i];
  return sum;
801039fc:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801039ff:	c9                   	leave  
80103a00:	c3                   	ret    

80103a01 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103a01:	55                   	push   %ebp
80103a02:	89 e5                	mov    %esp,%ebp
80103a04:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80103a07:	8b 45 08             	mov    0x8(%ebp),%eax
80103a0a:	05 00 00 00 80       	add    $0x80000000,%eax
80103a0f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103a12:	8b 55 0c             	mov    0xc(%ebp),%edx
80103a15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a18:	01 d0                	add    %edx,%eax
80103a1a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103a1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a20:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103a23:	eb 3f                	jmp    80103a64 <mpsearch1+0x63>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103a25:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103a2c:	00 
80103a2d:	c7 44 24 04 4c 88 10 	movl   $0x8010884c,0x4(%esp)
80103a34:	80 
80103a35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a38:	89 04 24             	mov    %eax,(%esp)
80103a3b:	e8 c1 17 00 00       	call   80105201 <memcmp>
80103a40:	85 c0                	test   %eax,%eax
80103a42:	75 1c                	jne    80103a60 <mpsearch1+0x5f>
80103a44:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103a4b:	00 
80103a4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a4f:	89 04 24             	mov    %eax,(%esp)
80103a52:	e8 74 ff ff ff       	call   801039cb <sum>
80103a57:	84 c0                	test   %al,%al
80103a59:	75 05                	jne    80103a60 <mpsearch1+0x5f>
      return (struct mp*)p;
80103a5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a5e:	eb 11                	jmp    80103a71 <mpsearch1+0x70>
{
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103a60:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103a64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a67:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103a6a:	72 b9                	jb     80103a25 <mpsearch1+0x24>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103a6c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103a71:	c9                   	leave  
80103a72:	c3                   	ret    

80103a73 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103a73:	55                   	push   %ebp
80103a74:	89 e5                	mov    %esp,%ebp
80103a76:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103a79:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103a80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a83:	83 c0 0f             	add    $0xf,%eax
80103a86:	8a 00                	mov    (%eax),%al
80103a88:	0f b6 c0             	movzbl %al,%eax
80103a8b:	c1 e0 08             	shl    $0x8,%eax
80103a8e:	89 c2                	mov    %eax,%edx
80103a90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a93:	83 c0 0e             	add    $0xe,%eax
80103a96:	8a 00                	mov    (%eax),%al
80103a98:	0f b6 c0             	movzbl %al,%eax
80103a9b:	09 d0                	or     %edx,%eax
80103a9d:	c1 e0 04             	shl    $0x4,%eax
80103aa0:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103aa3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103aa7:	74 21                	je     80103aca <mpsearch+0x57>
    if((mp = mpsearch1(p, 1024)))
80103aa9:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103ab0:	00 
80103ab1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ab4:	89 04 24             	mov    %eax,(%esp)
80103ab7:	e8 45 ff ff ff       	call   80103a01 <mpsearch1>
80103abc:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103abf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103ac3:	74 4e                	je     80103b13 <mpsearch+0xa0>
      return mp;
80103ac5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ac8:	eb 5d                	jmp    80103b27 <mpsearch+0xb4>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103aca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103acd:	83 c0 14             	add    $0x14,%eax
80103ad0:	8a 00                	mov    (%eax),%al
80103ad2:	0f b6 c0             	movzbl %al,%eax
80103ad5:	c1 e0 08             	shl    $0x8,%eax
80103ad8:	89 c2                	mov    %eax,%edx
80103ada:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103add:	83 c0 13             	add    $0x13,%eax
80103ae0:	8a 00                	mov    (%eax),%al
80103ae2:	0f b6 c0             	movzbl %al,%eax
80103ae5:	09 d0                	or     %edx,%eax
80103ae7:	c1 e0 0a             	shl    $0xa,%eax
80103aea:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103aed:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103af0:	2d 00 04 00 00       	sub    $0x400,%eax
80103af5:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103afc:	00 
80103afd:	89 04 24             	mov    %eax,(%esp)
80103b00:	e8 fc fe ff ff       	call   80103a01 <mpsearch1>
80103b05:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103b08:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b0c:	74 05                	je     80103b13 <mpsearch+0xa0>
      return mp;
80103b0e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b11:	eb 14                	jmp    80103b27 <mpsearch+0xb4>
  }
  return mpsearch1(0xF0000, 0x10000);
80103b13:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103b1a:	00 
80103b1b:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103b22:	e8 da fe ff ff       	call   80103a01 <mpsearch1>
}
80103b27:	c9                   	leave  
80103b28:	c3                   	ret    

80103b29 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103b29:	55                   	push   %ebp
80103b2a:	89 e5                	mov    %esp,%ebp
80103b2c:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103b2f:	e8 3f ff ff ff       	call   80103a73 <mpsearch>
80103b34:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b37:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103b3b:	74 0a                	je     80103b47 <mpconfig+0x1e>
80103b3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b40:	8b 40 04             	mov    0x4(%eax),%eax
80103b43:	85 c0                	test   %eax,%eax
80103b45:	75 07                	jne    80103b4e <mpconfig+0x25>
    return 0;
80103b47:	b8 00 00 00 00       	mov    $0x0,%eax
80103b4c:	eb 7d                	jmp    80103bcb <mpconfig+0xa2>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103b4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b51:	8b 40 04             	mov    0x4(%eax),%eax
80103b54:	05 00 00 00 80       	add    $0x80000000,%eax
80103b59:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103b5c:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103b63:	00 
80103b64:	c7 44 24 04 51 88 10 	movl   $0x80108851,0x4(%esp)
80103b6b:	80 
80103b6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b6f:	89 04 24             	mov    %eax,(%esp)
80103b72:	e8 8a 16 00 00       	call   80105201 <memcmp>
80103b77:	85 c0                	test   %eax,%eax
80103b79:	74 07                	je     80103b82 <mpconfig+0x59>
    return 0;
80103b7b:	b8 00 00 00 00       	mov    $0x0,%eax
80103b80:	eb 49                	jmp    80103bcb <mpconfig+0xa2>
  if(conf->version != 1 && conf->version != 4)
80103b82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b85:	8a 40 06             	mov    0x6(%eax),%al
80103b88:	3c 01                	cmp    $0x1,%al
80103b8a:	74 11                	je     80103b9d <mpconfig+0x74>
80103b8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b8f:	8a 40 06             	mov    0x6(%eax),%al
80103b92:	3c 04                	cmp    $0x4,%al
80103b94:	74 07                	je     80103b9d <mpconfig+0x74>
    return 0;
80103b96:	b8 00 00 00 00       	mov    $0x0,%eax
80103b9b:	eb 2e                	jmp    80103bcb <mpconfig+0xa2>
  if(sum((uchar*)conf, conf->length) != 0)
80103b9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ba0:	8b 40 04             	mov    0x4(%eax),%eax
80103ba3:	0f b7 c0             	movzwl %ax,%eax
80103ba6:	89 44 24 04          	mov    %eax,0x4(%esp)
80103baa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bad:	89 04 24             	mov    %eax,(%esp)
80103bb0:	e8 16 fe ff ff       	call   801039cb <sum>
80103bb5:	84 c0                	test   %al,%al
80103bb7:	74 07                	je     80103bc0 <mpconfig+0x97>
    return 0;
80103bb9:	b8 00 00 00 00       	mov    $0x0,%eax
80103bbe:	eb 0b                	jmp    80103bcb <mpconfig+0xa2>
  *pmp = mp;
80103bc0:	8b 45 08             	mov    0x8(%ebp),%eax
80103bc3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103bc6:	89 10                	mov    %edx,(%eax)
  return conf;
80103bc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103bcb:	c9                   	leave  
80103bcc:	c3                   	ret    

80103bcd <mpinit>:

void
mpinit(void)
{
80103bcd:	55                   	push   %ebp
80103bce:	89 e5                	mov    %esp,%ebp
80103bd0:	53                   	push   %ebx
80103bd1:	83 ec 34             	sub    $0x34,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103bd4:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103bd7:	89 04 24             	mov    %eax,(%esp)
80103bda:	e8 4a ff ff ff       	call   80103b29 <mpconfig>
80103bdf:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103be2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103be6:	75 05                	jne    80103bed <mpinit+0x20>
    return;
80103be8:	e9 2c 01 00 00       	jmp    80103d19 <mpinit+0x14c>
  ismp = 1;
80103bed:	c7 05 24 38 11 80 01 	movl   $0x1,0x80113824
80103bf4:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103bf7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bfa:	8b 40 24             	mov    0x24(%eax),%eax
80103bfd:	a3 3c 37 11 80       	mov    %eax,0x8011373c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103c02:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c05:	83 c0 2c             	add    $0x2c,%eax
80103c08:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c0e:	8b 40 04             	mov    0x4(%eax),%eax
80103c11:	0f b7 d0             	movzwl %ax,%edx
80103c14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c17:	01 d0                	add    %edx,%eax
80103c19:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c1c:	e9 86 00 00 00       	jmp    80103ca7 <mpinit+0xda>
    switch(*p){
80103c21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c24:	8a 00                	mov    (%eax),%al
80103c26:	0f b6 c0             	movzbl %al,%eax
80103c29:	83 f8 04             	cmp    $0x4,%eax
80103c2c:	77 6e                	ja     80103c9c <mpinit+0xcf>
80103c2e:	8b 04 85 58 88 10 80 	mov    -0x7fef77a8(,%eax,4),%eax
80103c35:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103c37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c3a:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu < NCPU) {
80103c3d:	a1 20 3e 11 80       	mov    0x80113e20,%eax
80103c42:	83 f8 07             	cmp    $0x7,%eax
80103c45:	7f 32                	jg     80103c79 <mpinit+0xac>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103c47:	8b 15 20 3e 11 80    	mov    0x80113e20,%edx
80103c4d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c50:	8a 48 01             	mov    0x1(%eax),%cl
80103c53:	89 d0                	mov    %edx,%eax
80103c55:	c1 e0 02             	shl    $0x2,%eax
80103c58:	01 d0                	add    %edx,%eax
80103c5a:	01 c0                	add    %eax,%eax
80103c5c:	01 d0                	add    %edx,%eax
80103c5e:	89 c3                	mov    %eax,%ebx
80103c60:	c1 e3 04             	shl    $0x4,%ebx
80103c63:	01 d8                	add    %ebx,%eax
80103c65:	01 d0                	add    %edx,%eax
80103c67:	05 40 38 11 80       	add    $0x80113840,%eax
80103c6c:	88 08                	mov    %cl,(%eax)
        ncpu++;
80103c6e:	a1 20 3e 11 80       	mov    0x80113e20,%eax
80103c73:	40                   	inc    %eax
80103c74:	a3 20 3e 11 80       	mov    %eax,0x80113e20
      }
      p += sizeof(struct mpproc);
80103c79:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103c7d:	eb 28                	jmp    80103ca7 <mpinit+0xda>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103c7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c82:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103c85:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103c88:	8a 40 01             	mov    0x1(%eax),%al
80103c8b:	a2 20 38 11 80       	mov    %al,0x80113820
      p += sizeof(struct mpioapic);
80103c90:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103c94:	eb 11                	jmp    80103ca7 <mpinit+0xda>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103c96:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103c9a:	eb 0b                	jmp    80103ca7 <mpinit+0xda>
    default:
      ismp = 0;
80103c9c:	c7 05 24 38 11 80 00 	movl   $0x0,0x80113824
80103ca3:	00 00 00 
      break;
80103ca6:	90                   	nop

  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103ca7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103caa:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103cad:	0f 82 6e ff ff ff    	jb     80103c21 <mpinit+0x54>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp){
80103cb3:	a1 24 38 11 80       	mov    0x80113824,%eax
80103cb8:	85 c0                	test   %eax,%eax
80103cba:	75 1d                	jne    80103cd9 <mpinit+0x10c>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103cbc:	c7 05 20 3e 11 80 01 	movl   $0x1,0x80113e20
80103cc3:	00 00 00 
    lapic = 0;
80103cc6:	c7 05 3c 37 11 80 00 	movl   $0x0,0x8011373c
80103ccd:	00 00 00 
    ioapicid = 0;
80103cd0:	c6 05 20 38 11 80 00 	movb   $0x0,0x80113820
    return;
80103cd7:	eb 40                	jmp    80103d19 <mpinit+0x14c>
  }

  if(mp->imcrp){
80103cd9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103cdc:	8a 40 0c             	mov    0xc(%eax),%al
80103cdf:	84 c0                	test   %al,%al
80103ce1:	74 36                	je     80103d19 <mpinit+0x14c>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103ce3:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103cea:	00 
80103ceb:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103cf2:	e8 b8 fc ff ff       	call   801039af <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103cf7:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103cfe:	e8 91 fc ff ff       	call   80103994 <inb>
80103d03:	83 c8 01             	or     $0x1,%eax
80103d06:	0f b6 c0             	movzbl %al,%eax
80103d09:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d0d:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103d14:	e8 96 fc ff ff       	call   801039af <outb>
  }
}
80103d19:	83 c4 34             	add    $0x34,%esp
80103d1c:	5b                   	pop    %ebx
80103d1d:	5d                   	pop    %ebp
80103d1e:	c3                   	ret    
	...

80103d20 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103d20:	55                   	push   %ebp
80103d21:	89 e5                	mov    %esp,%ebp
80103d23:	83 ec 08             	sub    $0x8,%esp
80103d26:	8b 45 08             	mov    0x8(%ebp),%eax
80103d29:	8b 55 0c             	mov    0xc(%ebp),%edx
80103d2c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103d30:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103d33:	8a 45 f8             	mov    -0x8(%ebp),%al
80103d36:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103d39:	ee                   	out    %al,(%dx)
}
80103d3a:	c9                   	leave  
80103d3b:	c3                   	ret    

80103d3c <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103d3c:	55                   	push   %ebp
80103d3d:	89 e5                	mov    %esp,%ebp
80103d3f:	83 ec 0c             	sub    $0xc,%esp
80103d42:	8b 45 08             	mov    0x8(%ebp),%eax
80103d45:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103d49:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103d4c:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
  outb(IO_PIC1+1, mask);
80103d52:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103d55:	0f b6 c0             	movzbl %al,%eax
80103d58:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d5c:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103d63:	e8 b8 ff ff ff       	call   80103d20 <outb>
  outb(IO_PIC2+1, mask >> 8);
80103d68:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103d6b:	66 c1 e8 08          	shr    $0x8,%ax
80103d6f:	0f b6 c0             	movzbl %al,%eax
80103d72:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d76:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103d7d:	e8 9e ff ff ff       	call   80103d20 <outb>
}
80103d82:	c9                   	leave  
80103d83:	c3                   	ret    

80103d84 <picenable>:

void
picenable(int irq)
{
80103d84:	55                   	push   %ebp
80103d85:	89 e5                	mov    %esp,%ebp
80103d87:	83 ec 04             	sub    $0x4,%esp
  picsetmask(irqmask & ~(1<<irq));
80103d8a:	8b 45 08             	mov    0x8(%ebp),%eax
80103d8d:	ba 01 00 00 00       	mov    $0x1,%edx
80103d92:	88 c1                	mov    %al,%cl
80103d94:	d3 e2                	shl    %cl,%edx
80103d96:	89 d0                	mov    %edx,%eax
80103d98:	f7 d0                	not    %eax
80103d9a:	89 c2                	mov    %eax,%edx
80103d9c:	66 a1 00 b0 10 80    	mov    0x8010b000,%ax
80103da2:	21 d0                	and    %edx,%eax
80103da4:	0f b7 c0             	movzwl %ax,%eax
80103da7:	89 04 24             	mov    %eax,(%esp)
80103daa:	e8 8d ff ff ff       	call   80103d3c <picsetmask>
}
80103daf:	c9                   	leave  
80103db0:	c3                   	ret    

80103db1 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103db1:	55                   	push   %ebp
80103db2:	89 e5                	mov    %esp,%ebp
80103db4:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103db7:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103dbe:	00 
80103dbf:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103dc6:	e8 55 ff ff ff       	call   80103d20 <outb>
  outb(IO_PIC2+1, 0xFF);
80103dcb:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103dd2:	00 
80103dd3:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103dda:	e8 41 ff ff ff       	call   80103d20 <outb>

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103ddf:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103de6:	00 
80103de7:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103dee:	e8 2d ff ff ff       	call   80103d20 <outb>

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103df3:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80103dfa:	00 
80103dfb:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e02:	e8 19 ff ff ff       	call   80103d20 <outb>

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103e07:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80103e0e:	00 
80103e0f:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e16:	e8 05 ff ff ff       	call   80103d20 <outb>
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103e1b:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103e22:	00 
80103e23:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e2a:	e8 f1 fe ff ff       	call   80103d20 <outb>

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103e2f:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103e36:	00 
80103e37:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103e3e:	e8 dd fe ff ff       	call   80103d20 <outb>
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103e43:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
80103e4a:	00 
80103e4b:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e52:	e8 c9 fe ff ff       	call   80103d20 <outb>
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103e57:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80103e5e:	00 
80103e5f:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e66:	e8 b5 fe ff ff       	call   80103d20 <outb>
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103e6b:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103e72:	00 
80103e73:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e7a:	e8 a1 fe ff ff       	call   80103d20 <outb>

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103e7f:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103e86:	00 
80103e87:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103e8e:	e8 8d fe ff ff       	call   80103d20 <outb>
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103e93:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103e9a:	00 
80103e9b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103ea2:	e8 79 fe ff ff       	call   80103d20 <outb>

  outb(IO_PIC2, 0x68);             // OCW3
80103ea7:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103eae:	00 
80103eaf:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103eb6:	e8 65 fe ff ff       	call   80103d20 <outb>
  outb(IO_PIC2, 0x0a);             // OCW3
80103ebb:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103ec2:	00 
80103ec3:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103eca:	e8 51 fe ff ff       	call   80103d20 <outb>

  if(irqmask != 0xFFFF)
80103ecf:	66 a1 00 b0 10 80    	mov    0x8010b000,%ax
80103ed5:	66 83 f8 ff          	cmp    $0xffffffff,%ax
80103ed9:	74 11                	je     80103eec <picinit+0x13b>
    picsetmask(irqmask);
80103edb:	66 a1 00 b0 10 80    	mov    0x8010b000,%ax
80103ee1:	0f b7 c0             	movzwl %ax,%eax
80103ee4:	89 04 24             	mov    %eax,(%esp)
80103ee7:	e8 50 fe ff ff       	call   80103d3c <picsetmask>
}
80103eec:	c9                   	leave  
80103eed:	c3                   	ret    
	...

80103ef0 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103ef0:	55                   	push   %ebp
80103ef1:	89 e5                	mov    %esp,%ebp
80103ef3:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103ef6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103efd:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f00:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103f06:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f09:	8b 10                	mov    (%eax),%edx
80103f0b:	8b 45 08             	mov    0x8(%ebp),%eax
80103f0e:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103f10:	e8 47 d0 ff ff       	call   80100f5c <filealloc>
80103f15:	8b 55 08             	mov    0x8(%ebp),%edx
80103f18:	89 02                	mov    %eax,(%edx)
80103f1a:	8b 45 08             	mov    0x8(%ebp),%eax
80103f1d:	8b 00                	mov    (%eax),%eax
80103f1f:	85 c0                	test   %eax,%eax
80103f21:	0f 84 c8 00 00 00    	je     80103fef <pipealloc+0xff>
80103f27:	e8 30 d0 ff ff       	call   80100f5c <filealloc>
80103f2c:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f2f:	89 02                	mov    %eax,(%edx)
80103f31:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f34:	8b 00                	mov    (%eax),%eax
80103f36:	85 c0                	test   %eax,%eax
80103f38:	0f 84 b1 00 00 00    	je     80103fef <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103f3e:	e8 20 ec ff ff       	call   80102b63 <kalloc>
80103f43:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103f46:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103f4a:	75 05                	jne    80103f51 <pipealloc+0x61>
    goto bad;
80103f4c:	e9 9e 00 00 00       	jmp    80103fef <pipealloc+0xff>
  p->readopen = 1;
80103f51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f54:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103f5b:	00 00 00 
  p->writeopen = 1;
80103f5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f61:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103f68:	00 00 00 
  p->nwrite = 0;
80103f6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f6e:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103f75:	00 00 00 
  p->nread = 0;
80103f78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f7b:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103f82:	00 00 00 
  initlock(&p->lock, "pipe");
80103f85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f88:	c7 44 24 04 6c 88 10 	movl   $0x8010886c,0x4(%esp)
80103f8f:	80 
80103f90:	89 04 24             	mov    %eax,(%esp)
80103f93:	e8 6e 0f 00 00       	call   80104f06 <initlock>
  (*f0)->type = FD_PIPE;
80103f98:	8b 45 08             	mov    0x8(%ebp),%eax
80103f9b:	8b 00                	mov    (%eax),%eax
80103f9d:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103fa3:	8b 45 08             	mov    0x8(%ebp),%eax
80103fa6:	8b 00                	mov    (%eax),%eax
80103fa8:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103fac:	8b 45 08             	mov    0x8(%ebp),%eax
80103faf:	8b 00                	mov    (%eax),%eax
80103fb1:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103fb5:	8b 45 08             	mov    0x8(%ebp),%eax
80103fb8:	8b 00                	mov    (%eax),%eax
80103fba:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103fbd:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103fc0:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fc3:	8b 00                	mov    (%eax),%eax
80103fc5:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103fcb:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fce:	8b 00                	mov    (%eax),%eax
80103fd0:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103fd4:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fd7:	8b 00                	mov    (%eax),%eax
80103fd9:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103fdd:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fe0:	8b 00                	mov    (%eax),%eax
80103fe2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103fe5:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103fe8:	b8 00 00 00 00       	mov    $0x0,%eax
80103fed:	eb 42                	jmp    80104031 <pipealloc+0x141>

//PAGEBREAK: 20
 bad:
  if(p)
80103fef:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103ff3:	74 0b                	je     80104000 <pipealloc+0x110>
    kfree((char*)p);
80103ff5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ff8:	89 04 24             	mov    %eax,(%esp)
80103ffb:	e8 cd ea ff ff       	call   80102acd <kfree>
  if(*f0)
80104000:	8b 45 08             	mov    0x8(%ebp),%eax
80104003:	8b 00                	mov    (%eax),%eax
80104005:	85 c0                	test   %eax,%eax
80104007:	74 0d                	je     80104016 <pipealloc+0x126>
    fileclose(*f0);
80104009:	8b 45 08             	mov    0x8(%ebp),%eax
8010400c:	8b 00                	mov    (%eax),%eax
8010400e:	89 04 24             	mov    %eax,(%esp)
80104011:	e8 ee cf ff ff       	call   80101004 <fileclose>
  if(*f1)
80104016:	8b 45 0c             	mov    0xc(%ebp),%eax
80104019:	8b 00                	mov    (%eax),%eax
8010401b:	85 c0                	test   %eax,%eax
8010401d:	74 0d                	je     8010402c <pipealloc+0x13c>
    fileclose(*f1);
8010401f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104022:	8b 00                	mov    (%eax),%eax
80104024:	89 04 24             	mov    %eax,(%esp)
80104027:	e8 d8 cf ff ff       	call   80101004 <fileclose>
  return -1;
8010402c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104031:	c9                   	leave  
80104032:	c3                   	ret    

80104033 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104033:	55                   	push   %ebp
80104034:	89 e5                	mov    %esp,%ebp
80104036:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
80104039:	8b 45 08             	mov    0x8(%ebp),%eax
8010403c:	89 04 24             	mov    %eax,(%esp)
8010403f:	e8 e3 0e 00 00       	call   80104f27 <acquire>
  if(writable){
80104044:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104048:	74 1f                	je     80104069 <pipeclose+0x36>
    p->writeopen = 0;
8010404a:	8b 45 08             	mov    0x8(%ebp),%eax
8010404d:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80104054:	00 00 00 
    wakeup(&p->nread);
80104057:	8b 45 08             	mov    0x8(%ebp),%eax
8010405a:	05 34 02 00 00       	add    $0x234,%eax
8010405f:	89 04 24             	mov    %eax,(%esp)
80104062:	e8 c8 0b 00 00       	call   80104c2f <wakeup>
80104067:	eb 1d                	jmp    80104086 <pipeclose+0x53>
  } else {
    p->readopen = 0;
80104069:	8b 45 08             	mov    0x8(%ebp),%eax
8010406c:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80104073:	00 00 00 
    wakeup(&p->nwrite);
80104076:	8b 45 08             	mov    0x8(%ebp),%eax
80104079:	05 38 02 00 00       	add    $0x238,%eax
8010407e:	89 04 24             	mov    %eax,(%esp)
80104081:	e8 a9 0b 00 00       	call   80104c2f <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104086:	8b 45 08             	mov    0x8(%ebp),%eax
80104089:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010408f:	85 c0                	test   %eax,%eax
80104091:	75 25                	jne    801040b8 <pipeclose+0x85>
80104093:	8b 45 08             	mov    0x8(%ebp),%eax
80104096:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010409c:	85 c0                	test   %eax,%eax
8010409e:	75 18                	jne    801040b8 <pipeclose+0x85>
    release(&p->lock);
801040a0:	8b 45 08             	mov    0x8(%ebp),%eax
801040a3:	89 04 24             	mov    %eax,(%esp)
801040a6:	e8 e3 0e 00 00       	call   80104f8e <release>
    kfree((char*)p);
801040ab:	8b 45 08             	mov    0x8(%ebp),%eax
801040ae:	89 04 24             	mov    %eax,(%esp)
801040b1:	e8 17 ea ff ff       	call   80102acd <kfree>
801040b6:	eb 0b                	jmp    801040c3 <pipeclose+0x90>
  } else
    release(&p->lock);
801040b8:	8b 45 08             	mov    0x8(%ebp),%eax
801040bb:	89 04 24             	mov    %eax,(%esp)
801040be:	e8 cb 0e 00 00       	call   80104f8e <release>
}
801040c3:	c9                   	leave  
801040c4:	c3                   	ret    

801040c5 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
801040c5:	55                   	push   %ebp
801040c6:	89 e5                	mov    %esp,%ebp
801040c8:	83 ec 28             	sub    $0x28,%esp
  int i;

  acquire(&p->lock);
801040cb:	8b 45 08             	mov    0x8(%ebp),%eax
801040ce:	89 04 24             	mov    %eax,(%esp)
801040d1:	e8 51 0e 00 00       	call   80104f27 <acquire>
  for(i = 0; i < n; i++){
801040d6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801040dd:	e9 a4 00 00 00       	jmp    80104186 <pipewrite+0xc1>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801040e2:	eb 57                	jmp    8010413b <pipewrite+0x76>
      if(p->readopen == 0 || proc->killed){
801040e4:	8b 45 08             	mov    0x8(%ebp),%eax
801040e7:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801040ed:	85 c0                	test   %eax,%eax
801040ef:	74 0d                	je     801040fe <pipewrite+0x39>
801040f1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801040f7:	8b 40 24             	mov    0x24(%eax),%eax
801040fa:	85 c0                	test   %eax,%eax
801040fc:	74 15                	je     80104113 <pipewrite+0x4e>
        release(&p->lock);
801040fe:	8b 45 08             	mov    0x8(%ebp),%eax
80104101:	89 04 24             	mov    %eax,(%esp)
80104104:	e8 85 0e 00 00       	call   80104f8e <release>
        return -1;
80104109:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010410e:	e9 9d 00 00 00       	jmp    801041b0 <pipewrite+0xeb>
      }
      wakeup(&p->nread);
80104113:	8b 45 08             	mov    0x8(%ebp),%eax
80104116:	05 34 02 00 00       	add    $0x234,%eax
8010411b:	89 04 24             	mov    %eax,(%esp)
8010411e:	e8 0c 0b 00 00       	call   80104c2f <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104123:	8b 45 08             	mov    0x8(%ebp),%eax
80104126:	8b 55 08             	mov    0x8(%ebp),%edx
80104129:	81 c2 38 02 00 00    	add    $0x238,%edx
8010412f:	89 44 24 04          	mov    %eax,0x4(%esp)
80104133:	89 14 24             	mov    %edx,(%esp)
80104136:	e8 1b 0a 00 00       	call   80104b56 <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
8010413b:	8b 45 08             	mov    0x8(%ebp),%eax
8010413e:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104144:	8b 45 08             	mov    0x8(%ebp),%eax
80104147:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010414d:	05 00 02 00 00       	add    $0x200,%eax
80104152:	39 c2                	cmp    %eax,%edx
80104154:	74 8e                	je     801040e4 <pipewrite+0x1f>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104156:	8b 45 08             	mov    0x8(%ebp),%eax
80104159:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010415f:	8d 48 01             	lea    0x1(%eax),%ecx
80104162:	8b 55 08             	mov    0x8(%ebp),%edx
80104165:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
8010416b:	25 ff 01 00 00       	and    $0x1ff,%eax
80104170:	89 c1                	mov    %eax,%ecx
80104172:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104175:	8b 45 0c             	mov    0xc(%ebp),%eax
80104178:	01 d0                	add    %edx,%eax
8010417a:	8a 10                	mov    (%eax),%dl
8010417c:	8b 45 08             	mov    0x8(%ebp),%eax
8010417f:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104183:	ff 45 f4             	incl   -0xc(%ebp)
80104186:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104189:	3b 45 10             	cmp    0x10(%ebp),%eax
8010418c:	0f 8c 50 ff ff ff    	jl     801040e2 <pipewrite+0x1d>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104192:	8b 45 08             	mov    0x8(%ebp),%eax
80104195:	05 34 02 00 00       	add    $0x234,%eax
8010419a:	89 04 24             	mov    %eax,(%esp)
8010419d:	e8 8d 0a 00 00       	call   80104c2f <wakeup>
  release(&p->lock);
801041a2:	8b 45 08             	mov    0x8(%ebp),%eax
801041a5:	89 04 24             	mov    %eax,(%esp)
801041a8:	e8 e1 0d 00 00       	call   80104f8e <release>
  return n;
801041ad:	8b 45 10             	mov    0x10(%ebp),%eax
}
801041b0:	c9                   	leave  
801041b1:	c3                   	ret    

801041b2 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801041b2:	55                   	push   %ebp
801041b3:	89 e5                	mov    %esp,%ebp
801041b5:	53                   	push   %ebx
801041b6:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
801041b9:	8b 45 08             	mov    0x8(%ebp),%eax
801041bc:	89 04 24             	mov    %eax,(%esp)
801041bf:	e8 63 0d 00 00       	call   80104f27 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801041c4:	eb 3a                	jmp    80104200 <piperead+0x4e>
    if(proc->killed){
801041c6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801041cc:	8b 40 24             	mov    0x24(%eax),%eax
801041cf:	85 c0                	test   %eax,%eax
801041d1:	74 15                	je     801041e8 <piperead+0x36>
      release(&p->lock);
801041d3:	8b 45 08             	mov    0x8(%ebp),%eax
801041d6:	89 04 24             	mov    %eax,(%esp)
801041d9:	e8 b0 0d 00 00       	call   80104f8e <release>
      return -1;
801041de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041e3:	e9 b3 00 00 00       	jmp    8010429b <piperead+0xe9>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801041e8:	8b 45 08             	mov    0x8(%ebp),%eax
801041eb:	8b 55 08             	mov    0x8(%ebp),%edx
801041ee:	81 c2 34 02 00 00    	add    $0x234,%edx
801041f4:	89 44 24 04          	mov    %eax,0x4(%esp)
801041f8:	89 14 24             	mov    %edx,(%esp)
801041fb:	e8 56 09 00 00       	call   80104b56 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104200:	8b 45 08             	mov    0x8(%ebp),%eax
80104203:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104209:	8b 45 08             	mov    0x8(%ebp),%eax
8010420c:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104212:	39 c2                	cmp    %eax,%edx
80104214:	75 0d                	jne    80104223 <piperead+0x71>
80104216:	8b 45 08             	mov    0x8(%ebp),%eax
80104219:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010421f:	85 c0                	test   %eax,%eax
80104221:	75 a3                	jne    801041c6 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104223:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010422a:	eb 49                	jmp    80104275 <piperead+0xc3>
    if(p->nread == p->nwrite)
8010422c:	8b 45 08             	mov    0x8(%ebp),%eax
8010422f:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104235:	8b 45 08             	mov    0x8(%ebp),%eax
80104238:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010423e:	39 c2                	cmp    %eax,%edx
80104240:	75 02                	jne    80104244 <piperead+0x92>
      break;
80104242:	eb 39                	jmp    8010427d <piperead+0xcb>
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104244:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104247:	8b 45 0c             	mov    0xc(%ebp),%eax
8010424a:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010424d:	8b 45 08             	mov    0x8(%ebp),%eax
80104250:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104256:	8d 48 01             	lea    0x1(%eax),%ecx
80104259:	8b 55 08             	mov    0x8(%ebp),%edx
8010425c:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104262:	25 ff 01 00 00       	and    $0x1ff,%eax
80104267:	89 c2                	mov    %eax,%edx
80104269:	8b 45 08             	mov    0x8(%ebp),%eax
8010426c:	8a 44 10 34          	mov    0x34(%eax,%edx,1),%al
80104270:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104272:	ff 45 f4             	incl   -0xc(%ebp)
80104275:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104278:	3b 45 10             	cmp    0x10(%ebp),%eax
8010427b:	7c af                	jl     8010422c <piperead+0x7a>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
8010427d:	8b 45 08             	mov    0x8(%ebp),%eax
80104280:	05 38 02 00 00       	add    $0x238,%eax
80104285:	89 04 24             	mov    %eax,(%esp)
80104288:	e8 a2 09 00 00       	call   80104c2f <wakeup>
  release(&p->lock);
8010428d:	8b 45 08             	mov    0x8(%ebp),%eax
80104290:	89 04 24             	mov    %eax,(%esp)
80104293:	e8 f6 0c 00 00       	call   80104f8e <release>
  return i;
80104298:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010429b:	83 c4 24             	add    $0x24,%esp
8010429e:	5b                   	pop    %ebx
8010429f:	5d                   	pop    %ebp
801042a0:	c3                   	ret    

801042a1 <pipe_count>:


int
pipe_count(struct pipe *p)
{
801042a1:	55                   	push   %ebp
801042a2:	89 e5                	mov    %esp,%ebp
801042a4:	83 ec 28             	sub    $0x28,%esp
  int pipe_bytes;

  acquire(&p->lock);
801042a7:	8b 45 08             	mov    0x8(%ebp),%eax
801042aa:	89 04 24             	mov    %eax,(%esp)
801042ad:	e8 75 0c 00 00       	call   80104f27 <acquire>
  
  int read_bytes = (int)p->nread;
801042b2:	8b 45 08             	mov    0x8(%ebp),%eax
801042b5:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801042bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  int write_bytes = (int)p->nwrite;
801042be:	8b 45 08             	mov    0x8(%ebp),%eax
801042c1:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801042c7:	89 45 f0             	mov    %eax,-0x10(%ebp)

  pipe_bytes = read_bytes-write_bytes;
801042ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801042cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042d0:	29 c2                	sub    %eax,%edx
801042d2:	89 d0                	mov    %edx,%eax
801042d4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  release(&p->lock);
801042d7:	8b 45 08             	mov    0x8(%ebp),%eax
801042da:	89 04 24             	mov    %eax,(%esp)
801042dd:	e8 ac 0c 00 00       	call   80104f8e <release>

  return pipe_bytes;
801042e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801042e5:	c9                   	leave  
801042e6:	c3                   	ret    
	...

801042e8 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801042e8:	55                   	push   %ebp
801042e9:	89 e5                	mov    %esp,%ebp
801042eb:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801042ee:	9c                   	pushf  
801042ef:	58                   	pop    %eax
801042f0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801042f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801042f6:	c9                   	leave  
801042f7:	c3                   	ret    

801042f8 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
801042f8:	55                   	push   %ebp
801042f9:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801042fb:	fb                   	sti    
}
801042fc:	5d                   	pop    %ebp
801042fd:	c3                   	ret    

801042fe <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
801042fe:	55                   	push   %ebp
801042ff:	89 e5                	mov    %esp,%ebp
80104301:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80104304:	c7 44 24 04 71 88 10 	movl   $0x80108871,0x4(%esp)
8010430b:	80 
8010430c:	c7 04 24 40 3e 11 80 	movl   $0x80113e40,(%esp)
80104313:	e8 ee 0b 00 00       	call   80104f06 <initlock>
}
80104318:	c9                   	leave  
80104319:	c3                   	ret    

8010431a <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
8010431a:	55                   	push   %ebp
8010431b:	89 e5                	mov    %esp,%ebp
8010431d:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104320:	c7 04 24 40 3e 11 80 	movl   $0x80113e40,(%esp)
80104327:	e8 fb 0b 00 00       	call   80104f27 <acquire>

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010432c:	c7 45 f4 74 3e 11 80 	movl   $0x80113e74,-0xc(%ebp)
80104333:	eb 50                	jmp    80104385 <allocproc+0x6b>
    if(p->state == UNUSED)
80104335:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104338:	8b 40 0c             	mov    0xc(%eax),%eax
8010433b:	85 c0                	test   %eax,%eax
8010433d:	75 42                	jne    80104381 <allocproc+0x67>
      goto found;
8010433f:	90                   	nop

  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
80104340:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104343:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
8010434a:	a1 04 b0 10 80       	mov    0x8010b004,%eax
8010434f:	8d 50 01             	lea    0x1(%eax),%edx
80104352:	89 15 04 b0 10 80    	mov    %edx,0x8010b004
80104358:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010435b:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
8010435e:	c7 04 24 40 3e 11 80 	movl   $0x80113e40,(%esp)
80104365:	e8 24 0c 00 00       	call   80104f8e <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
8010436a:	e8 f4 e7 ff ff       	call   80102b63 <kalloc>
8010436f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104372:	89 42 08             	mov    %eax,0x8(%edx)
80104375:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104378:	8b 40 08             	mov    0x8(%eax),%eax
8010437b:	85 c0                	test   %eax,%eax
8010437d:	75 33                	jne    801043b2 <allocproc+0x98>
8010437f:	eb 20                	jmp    801043a1 <allocproc+0x87>
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104381:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104385:	81 7d f4 74 5d 11 80 	cmpl   $0x80115d74,-0xc(%ebp)
8010438c:	72 a7                	jb     80104335 <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;

  release(&ptable.lock);
8010438e:	c7 04 24 40 3e 11 80 	movl   $0x80113e40,(%esp)
80104395:	e8 f4 0b 00 00       	call   80104f8e <release>
  return 0;
8010439a:	b8 00 00 00 00       	mov    $0x0,%eax
8010439f:	eb 76                	jmp    80104417 <allocproc+0xfd>

  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
801043a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043a4:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
801043ab:	b8 00 00 00 00       	mov    $0x0,%eax
801043b0:	eb 65                	jmp    80104417 <allocproc+0xfd>
  }
  sp = p->kstack + KSTACKSIZE;
801043b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043b5:	8b 40 08             	mov    0x8(%eax),%eax
801043b8:	05 00 10 00 00       	add    $0x1000,%eax
801043bd:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801043c0:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
801043c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043c7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043ca:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
801043cd:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
801043d1:	ba 68 66 10 80       	mov    $0x80106668,%edx
801043d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043d9:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
801043db:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
801043df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043e2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043e5:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
801043e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043eb:	8b 40 1c             	mov    0x1c(%eax),%eax
801043ee:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
801043f5:	00 
801043f6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801043fd:	00 
801043fe:	89 04 24             	mov    %eax,(%esp)
80104401:	e8 84 0d 00 00       	call   8010518a <memset>
  p->context->eip = (uint)forkret;
80104406:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104409:	8b 40 1c             	mov    0x1c(%eax),%eax
8010440c:	ba 17 4b 10 80       	mov    $0x80104b17,%edx
80104411:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80104414:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104417:	c9                   	leave  
80104418:	c3                   	ret    

80104419 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104419:	55                   	push   %ebp
8010441a:	89 e5                	mov    %esp,%ebp
8010441c:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
8010441f:	e8 f6 fe ff ff       	call   8010431a <allocproc>
80104424:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80104427:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010442a:	a3 64 b6 10 80       	mov    %eax,0x8010b664
  if((p->pgdir = setupkvm()) == 0)
8010442f:	e8 ac 38 00 00       	call   80107ce0 <setupkvm>
80104434:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104437:	89 42 04             	mov    %eax,0x4(%edx)
8010443a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010443d:	8b 40 04             	mov    0x4(%eax),%eax
80104440:	85 c0                	test   %eax,%eax
80104442:	75 0c                	jne    80104450 <userinit+0x37>
    panic("userinit: out of memory?");
80104444:	c7 04 24 78 88 10 80 	movl   $0x80108878,(%esp)
8010444b:	e8 04 c1 ff ff       	call   80100554 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104450:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104455:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104458:	8b 40 04             	mov    0x4(%eax),%eax
8010445b:	89 54 24 08          	mov    %edx,0x8(%esp)
8010445f:	c7 44 24 04 00 b5 10 	movl   $0x8010b500,0x4(%esp)
80104466:	80 
80104467:	89 04 24             	mov    %eax,(%esp)
8010446a:	e8 a1 3a 00 00       	call   80107f10 <inituvm>
  p->sz = PGSIZE;
8010446f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104472:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104478:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010447b:	8b 40 18             	mov    0x18(%eax),%eax
8010447e:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
80104485:	00 
80104486:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010448d:	00 
8010448e:	89 04 24             	mov    %eax,(%esp)
80104491:	e8 f4 0c 00 00       	call   8010518a <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104496:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104499:	8b 40 18             	mov    0x18(%eax),%eax
8010449c:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801044a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044a5:	8b 40 18             	mov    0x18(%eax),%eax
801044a8:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
801044ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044b1:	8b 50 18             	mov    0x18(%eax),%edx
801044b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044b7:	8b 40 18             	mov    0x18(%eax),%eax
801044ba:	8b 40 2c             	mov    0x2c(%eax),%eax
801044bd:	66 89 42 28          	mov    %ax,0x28(%edx)
  p->tf->ss = p->tf->ds;
801044c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044c4:	8b 50 18             	mov    0x18(%eax),%edx
801044c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ca:	8b 40 18             	mov    0x18(%eax),%eax
801044cd:	8b 40 2c             	mov    0x2c(%eax),%eax
801044d0:	66 89 42 48          	mov    %ax,0x48(%edx)
  p->tf->eflags = FL_IF;
801044d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044d7:	8b 40 18             	mov    0x18(%eax),%eax
801044da:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801044e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044e4:	8b 40 18             	mov    0x18(%eax),%eax
801044e7:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801044ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044f1:	8b 40 18             	mov    0x18(%eax),%eax
801044f4:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
801044fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044fe:	83 c0 6c             	add    $0x6c,%eax
80104501:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104508:	00 
80104509:	c7 44 24 04 91 88 10 	movl   $0x80108891,0x4(%esp)
80104510:	80 
80104511:	89 04 24             	mov    %eax,(%esp)
80104514:	e8 7d 0e 00 00       	call   80105396 <safestrcpy>
  p->cwd = namei("/");
80104519:	c7 04 24 9a 88 10 80 	movl   $0x8010889a,(%esp)
80104520:	e8 0c df ff ff       	call   80102431 <namei>
80104525:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104528:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
8010452b:	c7 04 24 40 3e 11 80 	movl   $0x80113e40,(%esp)
80104532:	e8 f0 09 00 00       	call   80104f27 <acquire>

  p->state = RUNNABLE;
80104537:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010453a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104541:	c7 04 24 40 3e 11 80 	movl   $0x80113e40,(%esp)
80104548:	e8 41 0a 00 00       	call   80104f8e <release>
}
8010454d:	c9                   	leave  
8010454e:	c3                   	ret    

8010454f <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
8010454f:	55                   	push   %ebp
80104550:	89 e5                	mov    %esp,%ebp
80104552:	83 ec 28             	sub    $0x28,%esp
  uint sz;

  sz = proc->sz;
80104555:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010455b:	8b 00                	mov    (%eax),%eax
8010455d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104560:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104564:	7e 34                	jle    8010459a <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
80104566:	8b 55 08             	mov    0x8(%ebp),%edx
80104569:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010456c:	01 c2                	add    %eax,%edx
8010456e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104574:	8b 40 04             	mov    0x4(%eax),%eax
80104577:	89 54 24 08          	mov    %edx,0x8(%esp)
8010457b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010457e:	89 54 24 04          	mov    %edx,0x4(%esp)
80104582:	89 04 24             	mov    %eax,(%esp)
80104585:	e8 f1 3a 00 00       	call   8010807b <allocuvm>
8010458a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010458d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104591:	75 41                	jne    801045d4 <growproc+0x85>
      return -1;
80104593:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104598:	eb 58                	jmp    801045f2 <growproc+0xa3>
  } else if(n < 0){
8010459a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010459e:	79 34                	jns    801045d4 <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
801045a0:	8b 55 08             	mov    0x8(%ebp),%edx
801045a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045a6:	01 c2                	add    %eax,%edx
801045a8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045ae:	8b 40 04             	mov    0x4(%eax),%eax
801045b1:	89 54 24 08          	mov    %edx,0x8(%esp)
801045b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045b8:	89 54 24 04          	mov    %edx,0x4(%esp)
801045bc:	89 04 24             	mov    %eax,(%esp)
801045bf:	e8 cd 3b 00 00       	call   80108191 <deallocuvm>
801045c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801045c7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801045cb:	75 07                	jne    801045d4 <growproc+0x85>
      return -1;
801045cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045d2:	eb 1e                	jmp    801045f2 <growproc+0xa3>
  }
  proc->sz = sz;
801045d4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045da:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045dd:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
801045df:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045e5:	89 04 24             	mov    %eax,(%esp)
801045e8:	e8 bf 37 00 00       	call   80107dac <switchuvm>
  return 0;
801045ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
801045f2:	c9                   	leave  
801045f3:	c3                   	ret    

801045f4 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
801045f4:	55                   	push   %ebp
801045f5:	89 e5                	mov    %esp,%ebp
801045f7:	57                   	push   %edi
801045f8:	56                   	push   %esi
801045f9:	53                   	push   %ebx
801045fa:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0){
801045fd:	e8 18 fd ff ff       	call   8010431a <allocproc>
80104602:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104605:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104609:	75 0a                	jne    80104615 <fork+0x21>
    return -1;
8010460b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104610:	e9 51 01 00 00       	jmp    80104766 <fork+0x172>
  }

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104615:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010461b:	8b 10                	mov    (%eax),%edx
8010461d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104623:	8b 40 04             	mov    0x4(%eax),%eax
80104626:	89 54 24 04          	mov    %edx,0x4(%esp)
8010462a:	89 04 24             	mov    %eax,(%esp)
8010462d:	e8 f1 3c 00 00       	call   80108323 <copyuvm>
80104632:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104635:	89 42 04             	mov    %eax,0x4(%edx)
80104638:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010463b:	8b 40 04             	mov    0x4(%eax),%eax
8010463e:	85 c0                	test   %eax,%eax
80104640:	75 2c                	jne    8010466e <fork+0x7a>
    kfree(np->kstack);
80104642:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104645:	8b 40 08             	mov    0x8(%eax),%eax
80104648:	89 04 24             	mov    %eax,(%esp)
8010464b:	e8 7d e4 ff ff       	call   80102acd <kfree>
    np->kstack = 0;
80104650:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104653:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
8010465a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010465d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104664:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104669:	e9 f8 00 00 00       	jmp    80104766 <fork+0x172>
  }
  np->sz = proc->sz;
8010466e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104674:	8b 10                	mov    (%eax),%edx
80104676:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104679:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
8010467b:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104682:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104685:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80104688:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010468b:	8b 50 18             	mov    0x18(%eax),%edx
8010468e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104694:	8b 40 18             	mov    0x18(%eax),%eax
80104697:	89 c3                	mov    %eax,%ebx
80104699:	b8 13 00 00 00       	mov    $0x13,%eax
8010469e:	89 d7                	mov    %edx,%edi
801046a0:	89 de                	mov    %ebx,%esi
801046a2:	89 c1                	mov    %eax,%ecx
801046a4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801046a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046a9:	8b 40 18             	mov    0x18(%eax),%eax
801046ac:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
801046b3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801046ba:	eb 3c                	jmp    801046f8 <fork+0x104>
    if(proc->ofile[i])
801046bc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046c2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801046c5:	83 c2 08             	add    $0x8,%edx
801046c8:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801046cc:	85 c0                	test   %eax,%eax
801046ce:	74 25                	je     801046f5 <fork+0x101>
      np->ofile[i] = filedup(proc->ofile[i]);
801046d0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046d6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801046d9:	83 c2 08             	add    $0x8,%edx
801046dc:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801046e0:	89 04 24             	mov    %eax,(%esp)
801046e3:	e8 d4 c8 ff ff       	call   80100fbc <filedup>
801046e8:	8b 55 e0             	mov    -0x20(%ebp),%edx
801046eb:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801046ee:	83 c1 08             	add    $0x8,%ecx
801046f1:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
801046f5:	ff 45 e4             	incl   -0x1c(%ebp)
801046f8:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
801046fc:	7e be                	jle    801046bc <fork+0xc8>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
801046fe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104704:	8b 40 68             	mov    0x68(%eax),%eax
80104707:	89 04 24             	mov    %eax,(%esp)
8010470a:	e8 dd d1 ff ff       	call   801018ec <idup>
8010470f:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104712:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104715:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010471b:	8d 50 6c             	lea    0x6c(%eax),%edx
8010471e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104721:	83 c0 6c             	add    $0x6c,%eax
80104724:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010472b:	00 
8010472c:	89 54 24 04          	mov    %edx,0x4(%esp)
80104730:	89 04 24             	mov    %eax,(%esp)
80104733:	e8 5e 0c 00 00       	call   80105396 <safestrcpy>

  pid = np->pid;
80104738:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010473b:	8b 40 10             	mov    0x10(%eax),%eax
8010473e:	89 45 dc             	mov    %eax,-0x24(%ebp)

  acquire(&ptable.lock);
80104741:	c7 04 24 40 3e 11 80 	movl   $0x80113e40,(%esp)
80104748:	e8 da 07 00 00       	call   80104f27 <acquire>

  np->state = RUNNABLE;
8010474d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104750:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104757:	c7 04 24 40 3e 11 80 	movl   $0x80113e40,(%esp)
8010475e:	e8 2b 08 00 00       	call   80104f8e <release>

  return pid;
80104763:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80104766:	83 c4 2c             	add    $0x2c,%esp
80104769:	5b                   	pop    %ebx
8010476a:	5e                   	pop    %esi
8010476b:	5f                   	pop    %edi
8010476c:	5d                   	pop    %ebp
8010476d:	c3                   	ret    

8010476e <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
8010476e:	55                   	push   %ebp
8010476f:	89 e5                	mov    %esp,%ebp
80104771:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
80104774:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010477b:	a1 64 b6 10 80       	mov    0x8010b664,%eax
80104780:	39 c2                	cmp    %eax,%edx
80104782:	75 0c                	jne    80104790 <exit+0x22>
    panic("init exiting");
80104784:	c7 04 24 9c 88 10 80 	movl   $0x8010889c,(%esp)
8010478b:	e8 c4 bd ff ff       	call   80100554 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104790:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104797:	eb 43                	jmp    801047dc <exit+0x6e>
    if(proc->ofile[fd]){
80104799:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010479f:	8b 55 f0             	mov    -0x10(%ebp),%edx
801047a2:	83 c2 08             	add    $0x8,%edx
801047a5:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801047a9:	85 c0                	test   %eax,%eax
801047ab:	74 2c                	je     801047d9 <exit+0x6b>
      fileclose(proc->ofile[fd]);
801047ad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047b3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801047b6:	83 c2 08             	add    $0x8,%edx
801047b9:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801047bd:	89 04 24             	mov    %eax,(%esp)
801047c0:	e8 3f c8 ff ff       	call   80101004 <fileclose>
      proc->ofile[fd] = 0;
801047c5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047cb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801047ce:	83 c2 08             	add    $0x8,%edx
801047d1:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801047d8:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801047d9:	ff 45 f0             	incl   -0x10(%ebp)
801047dc:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801047e0:	7e b7                	jle    80104799 <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
801047e2:	e8 dc ec ff ff       	call   801034c3 <begin_op>
  iput(proc->cwd);
801047e7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047ed:	8b 40 68             	mov    0x68(%eax),%eax
801047f0:	89 04 24             	mov    %eax,(%esp)
801047f3:	e8 7e d2 ff ff       	call   80101a76 <iput>
  end_op();
801047f8:	e8 48 ed ff ff       	call   80103545 <end_op>
  proc->cwd = 0;
801047fd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104803:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
8010480a:	c7 04 24 40 3e 11 80 	movl   $0x80113e40,(%esp)
80104811:	e8 11 07 00 00       	call   80104f27 <acquire>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104816:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010481c:	8b 40 14             	mov    0x14(%eax),%eax
8010481f:	89 04 24             	mov    %eax,(%esp)
80104822:	e8 ca 03 00 00       	call   80104bf1 <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104827:	c7 45 f4 74 3e 11 80 	movl   $0x80113e74,-0xc(%ebp)
8010482e:	eb 38                	jmp    80104868 <exit+0xfa>
    if(p->parent == proc){
80104830:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104833:	8b 50 14             	mov    0x14(%eax),%edx
80104836:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010483c:	39 c2                	cmp    %eax,%edx
8010483e:	75 24                	jne    80104864 <exit+0xf6>
      p->parent = initproc;
80104840:	8b 15 64 b6 10 80    	mov    0x8010b664,%edx
80104846:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104849:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
8010484c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010484f:	8b 40 0c             	mov    0xc(%eax),%eax
80104852:	83 f8 05             	cmp    $0x5,%eax
80104855:	75 0d                	jne    80104864 <exit+0xf6>
        wakeup1(initproc);
80104857:	a1 64 b6 10 80       	mov    0x8010b664,%eax
8010485c:	89 04 24             	mov    %eax,(%esp)
8010485f:	e8 8d 03 00 00       	call   80104bf1 <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104864:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104868:	81 7d f4 74 5d 11 80 	cmpl   $0x80115d74,-0xc(%ebp)
8010486f:	72 bf                	jb     80104830 <exit+0xc2>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80104871:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104877:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
8010487e:	e8 b0 01 00 00       	call   80104a33 <sched>
  panic("zombie exit");
80104883:	c7 04 24 a9 88 10 80 	movl   $0x801088a9,(%esp)
8010488a:	e8 c5 bc ff ff       	call   80100554 <panic>

8010488f <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
8010488f:	55                   	push   %ebp
80104890:	89 e5                	mov    %esp,%ebp
80104892:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104895:	c7 04 24 40 3e 11 80 	movl   $0x80113e40,(%esp)
8010489c:	e8 86 06 00 00       	call   80104f27 <acquire>
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
801048a1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048a8:	c7 45 f4 74 3e 11 80 	movl   $0x80113e74,-0xc(%ebp)
801048af:	e9 9a 00 00 00       	jmp    8010494e <wait+0xbf>
      if(p->parent != proc)
801048b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048b7:	8b 50 14             	mov    0x14(%eax),%edx
801048ba:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048c0:	39 c2                	cmp    %eax,%edx
801048c2:	74 05                	je     801048c9 <wait+0x3a>
        continue;
801048c4:	e9 81 00 00 00       	jmp    8010494a <wait+0xbb>
      havekids = 1;
801048c9:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801048d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048d3:	8b 40 0c             	mov    0xc(%eax),%eax
801048d6:	83 f8 05             	cmp    $0x5,%eax
801048d9:	75 6f                	jne    8010494a <wait+0xbb>
        // Found one.
        pid = p->pid;
801048db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048de:	8b 40 10             	mov    0x10(%eax),%eax
801048e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
801048e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048e7:	8b 40 08             	mov    0x8(%eax),%eax
801048ea:	89 04 24             	mov    %eax,(%esp)
801048ed:	e8 db e1 ff ff       	call   80102acd <kfree>
        p->kstack = 0;
801048f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048f5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801048fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048ff:	8b 40 04             	mov    0x4(%eax),%eax
80104902:	89 04 24             	mov    %eax,(%esp)
80104905:	e8 3d 39 00 00       	call   80108247 <freevm>
        p->pid = 0;
8010490a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010490d:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104914:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104917:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
8010491e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104921:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104925:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104928:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
8010492f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104932:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104939:	c7 04 24 40 3e 11 80 	movl   $0x80113e40,(%esp)
80104940:	e8 49 06 00 00       	call   80104f8e <release>
        return pid;
80104945:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104948:	eb 52                	jmp    8010499c <wait+0x10d>

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010494a:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
8010494e:	81 7d f4 74 5d 11 80 	cmpl   $0x80115d74,-0xc(%ebp)
80104955:	0f 82 59 ff ff ff    	jb     801048b4 <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
8010495b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010495f:	74 0d                	je     8010496e <wait+0xdf>
80104961:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104967:	8b 40 24             	mov    0x24(%eax),%eax
8010496a:	85 c0                	test   %eax,%eax
8010496c:	74 13                	je     80104981 <wait+0xf2>
      release(&ptable.lock);
8010496e:	c7 04 24 40 3e 11 80 	movl   $0x80113e40,(%esp)
80104975:	e8 14 06 00 00       	call   80104f8e <release>
      return -1;
8010497a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010497f:	eb 1b                	jmp    8010499c <wait+0x10d>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104981:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104987:	c7 44 24 04 40 3e 11 	movl   $0x80113e40,0x4(%esp)
8010498e:	80 
8010498f:	89 04 24             	mov    %eax,(%esp)
80104992:	e8 bf 01 00 00       	call   80104b56 <sleep>
  }
80104997:	e9 05 ff ff ff       	jmp    801048a1 <wait+0x12>
}
8010499c:	c9                   	leave  
8010499d:	c3                   	ret    

8010499e <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
8010499e:	55                   	push   %ebp
8010499f:	89 e5                	mov    %esp,%ebp
801049a1:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
801049a4:	e8 4f f9 ff ff       	call   801042f8 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
801049a9:	c7 04 24 40 3e 11 80 	movl   $0x80113e40,(%esp)
801049b0:	e8 72 05 00 00       	call   80104f27 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049b5:	c7 45 f4 74 3e 11 80 	movl   $0x80113e74,-0xc(%ebp)
801049bc:	eb 5b                	jmp    80104a19 <scheduler+0x7b>
      if(p->state != RUNNABLE)
801049be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049c1:	8b 40 0c             	mov    0xc(%eax),%eax
801049c4:	83 f8 03             	cmp    $0x3,%eax
801049c7:	74 02                	je     801049cb <scheduler+0x2d>
        continue;
801049c9:	eb 4a                	jmp    80104a15 <scheduler+0x77>

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
801049cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049ce:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
801049d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049d7:	89 04 24             	mov    %eax,(%esp)
801049da:	e8 cd 33 00 00       	call   80107dac <switchuvm>
      p->state = RUNNING;
801049df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049e2:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, p->context);
801049e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049ec:	8b 40 1c             	mov    0x1c(%eax),%eax
801049ef:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801049f6:	83 c2 04             	add    $0x4,%edx
801049f9:	89 44 24 04          	mov    %eax,0x4(%esp)
801049fd:	89 14 24             	mov    %edx,(%esp)
80104a00:	e8 ff 09 00 00       	call   80105404 <swtch>
      switchkvm();
80104a05:	e8 88 33 00 00       	call   80107d92 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104a0a:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104a11:	00 00 00 00 
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a15:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104a19:	81 7d f4 74 5d 11 80 	cmpl   $0x80115d74,-0xc(%ebp)
80104a20:	72 9c                	jb     801049be <scheduler+0x20>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
80104a22:	c7 04 24 40 3e 11 80 	movl   $0x80113e40,(%esp)
80104a29:	e8 60 05 00 00       	call   80104f8e <release>

  }
80104a2e:	e9 71 ff ff ff       	jmp    801049a4 <scheduler+0x6>

80104a33 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104a33:	55                   	push   %ebp
80104a34:	89 e5                	mov    %esp,%ebp
80104a36:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
80104a39:	c7 04 24 40 3e 11 80 	movl   $0x80113e40,(%esp)
80104a40:	e8 0d 06 00 00       	call   80105052 <holding>
80104a45:	85 c0                	test   %eax,%eax
80104a47:	75 0c                	jne    80104a55 <sched+0x22>
    panic("sched ptable.lock");
80104a49:	c7 04 24 b5 88 10 80 	movl   $0x801088b5,(%esp)
80104a50:	e8 ff ba ff ff       	call   80100554 <panic>
  if(cpu->ncli != 1)
80104a55:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104a5b:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104a61:	83 f8 01             	cmp    $0x1,%eax
80104a64:	74 0c                	je     80104a72 <sched+0x3f>
    panic("sched locks");
80104a66:	c7 04 24 c7 88 10 80 	movl   $0x801088c7,(%esp)
80104a6d:	e8 e2 ba ff ff       	call   80100554 <panic>
  if(proc->state == RUNNING)
80104a72:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a78:	8b 40 0c             	mov    0xc(%eax),%eax
80104a7b:	83 f8 04             	cmp    $0x4,%eax
80104a7e:	75 0c                	jne    80104a8c <sched+0x59>
    panic("sched running");
80104a80:	c7 04 24 d3 88 10 80 	movl   $0x801088d3,(%esp)
80104a87:	e8 c8 ba ff ff       	call   80100554 <panic>
  if(readeflags()&FL_IF)
80104a8c:	e8 57 f8 ff ff       	call   801042e8 <readeflags>
80104a91:	25 00 02 00 00       	and    $0x200,%eax
80104a96:	85 c0                	test   %eax,%eax
80104a98:	74 0c                	je     80104aa6 <sched+0x73>
    panic("sched interruptible");
80104a9a:	c7 04 24 e1 88 10 80 	movl   $0x801088e1,(%esp)
80104aa1:	e8 ae ba ff ff       	call   80100554 <panic>
  intena = cpu->intena;
80104aa6:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104aac:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104ab2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104ab5:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104abb:	8b 40 04             	mov    0x4(%eax),%eax
80104abe:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104ac5:	83 c2 1c             	add    $0x1c,%edx
80104ac8:	89 44 24 04          	mov    %eax,0x4(%esp)
80104acc:	89 14 24             	mov    %edx,(%esp)
80104acf:	e8 30 09 00 00       	call   80105404 <swtch>
  cpu->intena = intena;
80104ad4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104ada:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104add:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104ae3:	c9                   	leave  
80104ae4:	c3                   	ret    

80104ae5 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104ae5:	55                   	push   %ebp
80104ae6:	89 e5                	mov    %esp,%ebp
80104ae8:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104aeb:	c7 04 24 40 3e 11 80 	movl   $0x80113e40,(%esp)
80104af2:	e8 30 04 00 00       	call   80104f27 <acquire>
  proc->state = RUNNABLE;
80104af7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104afd:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104b04:	e8 2a ff ff ff       	call   80104a33 <sched>
  release(&ptable.lock);
80104b09:	c7 04 24 40 3e 11 80 	movl   $0x80113e40,(%esp)
80104b10:	e8 79 04 00 00       	call   80104f8e <release>
}
80104b15:	c9                   	leave  
80104b16:	c3                   	ret    

80104b17 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104b17:	55                   	push   %ebp
80104b18:	89 e5                	mov    %esp,%ebp
80104b1a:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104b1d:	c7 04 24 40 3e 11 80 	movl   $0x80113e40,(%esp)
80104b24:	e8 65 04 00 00       	call   80104f8e <release>

  if (first) {
80104b29:	a1 08 b0 10 80       	mov    0x8010b008,%eax
80104b2e:	85 c0                	test   %eax,%eax
80104b30:	74 22                	je     80104b54 <forkret+0x3d>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104b32:	c7 05 08 b0 10 80 00 	movl   $0x0,0x8010b008
80104b39:	00 00 00 
    iinit(ROOTDEV);
80104b3c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104b43:	e8 6f ca ff ff       	call   801015b7 <iinit>
    initlog(ROOTDEV);
80104b48:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104b4f:	e8 70 e7 ff ff       	call   801032c4 <initlog>
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104b54:	c9                   	leave  
80104b55:	c3                   	ret    

80104b56 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104b56:	55                   	push   %ebp
80104b57:	89 e5                	mov    %esp,%ebp
80104b59:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
80104b5c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b62:	85 c0                	test   %eax,%eax
80104b64:	75 0c                	jne    80104b72 <sleep+0x1c>
    panic("sleep");
80104b66:	c7 04 24 f5 88 10 80 	movl   $0x801088f5,(%esp)
80104b6d:	e8 e2 b9 ff ff       	call   80100554 <panic>

  if(lk == 0)
80104b72:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104b76:	75 0c                	jne    80104b84 <sleep+0x2e>
    panic("sleep without lk");
80104b78:	c7 04 24 fb 88 10 80 	movl   $0x801088fb,(%esp)
80104b7f:	e8 d0 b9 ff ff       	call   80100554 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104b84:	81 7d 0c 40 3e 11 80 	cmpl   $0x80113e40,0xc(%ebp)
80104b8b:	74 17                	je     80104ba4 <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104b8d:	c7 04 24 40 3e 11 80 	movl   $0x80113e40,(%esp)
80104b94:	e8 8e 03 00 00       	call   80104f27 <acquire>
    release(lk);
80104b99:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b9c:	89 04 24             	mov    %eax,(%esp)
80104b9f:	e8 ea 03 00 00       	call   80104f8e <release>
  }

  // Go to sleep.
  proc->chan = chan;
80104ba4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104baa:	8b 55 08             	mov    0x8(%ebp),%edx
80104bad:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104bb0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bb6:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80104bbd:	e8 71 fe ff ff       	call   80104a33 <sched>

  // Tidy up.
  proc->chan = 0;
80104bc2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bc8:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104bcf:	81 7d 0c 40 3e 11 80 	cmpl   $0x80113e40,0xc(%ebp)
80104bd6:	74 17                	je     80104bef <sleep+0x99>
    release(&ptable.lock);
80104bd8:	c7 04 24 40 3e 11 80 	movl   $0x80113e40,(%esp)
80104bdf:	e8 aa 03 00 00       	call   80104f8e <release>
    acquire(lk);
80104be4:	8b 45 0c             	mov    0xc(%ebp),%eax
80104be7:	89 04 24             	mov    %eax,(%esp)
80104bea:	e8 38 03 00 00       	call   80104f27 <acquire>
  }
}
80104bef:	c9                   	leave  
80104bf0:	c3                   	ret    

80104bf1 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104bf1:	55                   	push   %ebp
80104bf2:	89 e5                	mov    %esp,%ebp
80104bf4:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104bf7:	c7 45 fc 74 3e 11 80 	movl   $0x80113e74,-0x4(%ebp)
80104bfe:	eb 24                	jmp    80104c24 <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104c00:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c03:	8b 40 0c             	mov    0xc(%eax),%eax
80104c06:	83 f8 02             	cmp    $0x2,%eax
80104c09:	75 15                	jne    80104c20 <wakeup1+0x2f>
80104c0b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c0e:	8b 40 20             	mov    0x20(%eax),%eax
80104c11:	3b 45 08             	cmp    0x8(%ebp),%eax
80104c14:	75 0a                	jne    80104c20 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104c16:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c19:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104c20:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
80104c24:	81 7d fc 74 5d 11 80 	cmpl   $0x80115d74,-0x4(%ebp)
80104c2b:	72 d3                	jb     80104c00 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104c2d:	c9                   	leave  
80104c2e:	c3                   	ret    

80104c2f <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104c2f:	55                   	push   %ebp
80104c30:	89 e5                	mov    %esp,%ebp
80104c32:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104c35:	c7 04 24 40 3e 11 80 	movl   $0x80113e40,(%esp)
80104c3c:	e8 e6 02 00 00       	call   80104f27 <acquire>
  wakeup1(chan);
80104c41:	8b 45 08             	mov    0x8(%ebp),%eax
80104c44:	89 04 24             	mov    %eax,(%esp)
80104c47:	e8 a5 ff ff ff       	call   80104bf1 <wakeup1>
  release(&ptable.lock);
80104c4c:	c7 04 24 40 3e 11 80 	movl   $0x80113e40,(%esp)
80104c53:	e8 36 03 00 00       	call   80104f8e <release>
}
80104c58:	c9                   	leave  
80104c59:	c3                   	ret    

80104c5a <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104c5a:	55                   	push   %ebp
80104c5b:	89 e5                	mov    %esp,%ebp
80104c5d:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104c60:	c7 04 24 40 3e 11 80 	movl   $0x80113e40,(%esp)
80104c67:	e8 bb 02 00 00       	call   80104f27 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c6c:	c7 45 f4 74 3e 11 80 	movl   $0x80113e74,-0xc(%ebp)
80104c73:	eb 41                	jmp    80104cb6 <kill+0x5c>
    if(p->pid == pid){
80104c75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c78:	8b 40 10             	mov    0x10(%eax),%eax
80104c7b:	3b 45 08             	cmp    0x8(%ebp),%eax
80104c7e:	75 32                	jne    80104cb2 <kill+0x58>
      p->killed = 1;
80104c80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c83:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104c8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c8d:	8b 40 0c             	mov    0xc(%eax),%eax
80104c90:	83 f8 02             	cmp    $0x2,%eax
80104c93:	75 0a                	jne    80104c9f <kill+0x45>
        p->state = RUNNABLE;
80104c95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c98:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104c9f:	c7 04 24 40 3e 11 80 	movl   $0x80113e40,(%esp)
80104ca6:	e8 e3 02 00 00       	call   80104f8e <release>
      return 0;
80104cab:	b8 00 00 00 00       	mov    $0x0,%eax
80104cb0:	eb 1e                	jmp    80104cd0 <kill+0x76>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104cb2:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104cb6:	81 7d f4 74 5d 11 80 	cmpl   $0x80115d74,-0xc(%ebp)
80104cbd:	72 b6                	jb     80104c75 <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104cbf:	c7 04 24 40 3e 11 80 	movl   $0x80113e40,(%esp)
80104cc6:	e8 c3 02 00 00       	call   80104f8e <release>
  return -1;
80104ccb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104cd0:	c9                   	leave  
80104cd1:	c3                   	ret    

80104cd2 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104cd2:	55                   	push   %ebp
80104cd3:	89 e5                	mov    %esp,%ebp
80104cd5:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104cd8:	c7 45 f0 74 3e 11 80 	movl   $0x80113e74,-0x10(%ebp)
80104cdf:	e9 d5 00 00 00       	jmp    80104db9 <procdump+0xe7>
    if(p->state == UNUSED)
80104ce4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ce7:	8b 40 0c             	mov    0xc(%eax),%eax
80104cea:	85 c0                	test   %eax,%eax
80104cec:	75 05                	jne    80104cf3 <procdump+0x21>
      continue;
80104cee:	e9 c2 00 00 00       	jmp    80104db5 <procdump+0xe3>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104cf3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cf6:	8b 40 0c             	mov    0xc(%eax),%eax
80104cf9:	83 f8 05             	cmp    $0x5,%eax
80104cfc:	77 23                	ja     80104d21 <procdump+0x4f>
80104cfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d01:	8b 40 0c             	mov    0xc(%eax),%eax
80104d04:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104d0b:	85 c0                	test   %eax,%eax
80104d0d:	74 12                	je     80104d21 <procdump+0x4f>
      state = states[p->state];
80104d0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d12:	8b 40 0c             	mov    0xc(%eax),%eax
80104d15:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104d1c:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104d1f:	eb 07                	jmp    80104d28 <procdump+0x56>
    else
      state = "???";
80104d21:	c7 45 ec 0c 89 10 80 	movl   $0x8010890c,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104d28:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d2b:	8d 50 6c             	lea    0x6c(%eax),%edx
80104d2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d31:	8b 40 10             	mov    0x10(%eax),%eax
80104d34:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104d38:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104d3b:	89 54 24 08          	mov    %edx,0x8(%esp)
80104d3f:	89 44 24 04          	mov    %eax,0x4(%esp)
80104d43:	c7 04 24 10 89 10 80 	movl   $0x80108910,(%esp)
80104d4a:	e8 72 b6 ff ff       	call   801003c1 <cprintf>
    if(p->state == SLEEPING){
80104d4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d52:	8b 40 0c             	mov    0xc(%eax),%eax
80104d55:	83 f8 02             	cmp    $0x2,%eax
80104d58:	75 4f                	jne    80104da9 <procdump+0xd7>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104d5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d5d:	8b 40 1c             	mov    0x1c(%eax),%eax
80104d60:	8b 40 0c             	mov    0xc(%eax),%eax
80104d63:	83 c0 08             	add    $0x8,%eax
80104d66:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80104d69:	89 54 24 04          	mov    %edx,0x4(%esp)
80104d6d:	89 04 24             	mov    %eax,(%esp)
80104d70:	e8 66 02 00 00       	call   80104fdb <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104d75:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104d7c:	eb 1a                	jmp    80104d98 <procdump+0xc6>
        cprintf(" %p", pc[i]);
80104d7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d81:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104d85:	89 44 24 04          	mov    %eax,0x4(%esp)
80104d89:	c7 04 24 19 89 10 80 	movl   $0x80108919,(%esp)
80104d90:	e8 2c b6 ff ff       	call   801003c1 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104d95:	ff 45 f4             	incl   -0xc(%ebp)
80104d98:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104d9c:	7f 0b                	jg     80104da9 <procdump+0xd7>
80104d9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104da1:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104da5:	85 c0                	test   %eax,%eax
80104da7:	75 d5                	jne    80104d7e <procdump+0xac>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104da9:	c7 04 24 1d 89 10 80 	movl   $0x8010891d,(%esp)
80104db0:	e8 0c b6 ff ff       	call   801003c1 <cprintf>
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104db5:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
80104db9:	81 7d f0 74 5d 11 80 	cmpl   $0x80115d74,-0x10(%ebp)
80104dc0:	0f 82 1e ff ff ff    	jb     80104ce4 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104dc6:	c9                   	leave  
80104dc7:	c3                   	ret    

80104dc8 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104dc8:	55                   	push   %ebp
80104dc9:	89 e5                	mov    %esp,%ebp
80104dcb:	83 ec 18             	sub    $0x18,%esp
  initlock(&lk->lk, "sleep lock");
80104dce:	8b 45 08             	mov    0x8(%ebp),%eax
80104dd1:	83 c0 04             	add    $0x4,%eax
80104dd4:	c7 44 24 04 49 89 10 	movl   $0x80108949,0x4(%esp)
80104ddb:	80 
80104ddc:	89 04 24             	mov    %eax,(%esp)
80104ddf:	e8 22 01 00 00       	call   80104f06 <initlock>
  lk->name = name;
80104de4:	8b 45 08             	mov    0x8(%ebp),%eax
80104de7:	8b 55 0c             	mov    0xc(%ebp),%edx
80104dea:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104ded:	8b 45 08             	mov    0x8(%ebp),%eax
80104df0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104df6:	8b 45 08             	mov    0x8(%ebp),%eax
80104df9:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104e00:	c9                   	leave  
80104e01:	c3                   	ret    

80104e02 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104e02:	55                   	push   %ebp
80104e03:	89 e5                	mov    %esp,%ebp
80104e05:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
80104e08:	8b 45 08             	mov    0x8(%ebp),%eax
80104e0b:	83 c0 04             	add    $0x4,%eax
80104e0e:	89 04 24             	mov    %eax,(%esp)
80104e11:	e8 11 01 00 00       	call   80104f27 <acquire>
  while (lk->locked) {
80104e16:	eb 15                	jmp    80104e2d <acquiresleep+0x2b>
    sleep(lk, &lk->lk);
80104e18:	8b 45 08             	mov    0x8(%ebp),%eax
80104e1b:	83 c0 04             	add    $0x4,%eax
80104e1e:	89 44 24 04          	mov    %eax,0x4(%esp)
80104e22:	8b 45 08             	mov    0x8(%ebp),%eax
80104e25:	89 04 24             	mov    %eax,(%esp)
80104e28:	e8 29 fd ff ff       	call   80104b56 <sleep>

void
acquiresleep(struct sleeplock *lk)
{
  acquire(&lk->lk);
  while (lk->locked) {
80104e2d:	8b 45 08             	mov    0x8(%ebp),%eax
80104e30:	8b 00                	mov    (%eax),%eax
80104e32:	85 c0                	test   %eax,%eax
80104e34:	75 e2                	jne    80104e18 <acquiresleep+0x16>
    sleep(lk, &lk->lk);
  }
  lk->locked = 1;
80104e36:	8b 45 08             	mov    0x8(%ebp),%eax
80104e39:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = proc->pid;
80104e3f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e45:	8b 50 10             	mov    0x10(%eax),%edx
80104e48:	8b 45 08             	mov    0x8(%ebp),%eax
80104e4b:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104e4e:	8b 45 08             	mov    0x8(%ebp),%eax
80104e51:	83 c0 04             	add    $0x4,%eax
80104e54:	89 04 24             	mov    %eax,(%esp)
80104e57:	e8 32 01 00 00       	call   80104f8e <release>
}
80104e5c:	c9                   	leave  
80104e5d:	c3                   	ret    

80104e5e <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104e5e:	55                   	push   %ebp
80104e5f:	89 e5                	mov    %esp,%ebp
80104e61:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
80104e64:	8b 45 08             	mov    0x8(%ebp),%eax
80104e67:	83 c0 04             	add    $0x4,%eax
80104e6a:	89 04 24             	mov    %eax,(%esp)
80104e6d:	e8 b5 00 00 00       	call   80104f27 <acquire>
  lk->locked = 0;
80104e72:	8b 45 08             	mov    0x8(%ebp),%eax
80104e75:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104e7b:	8b 45 08             	mov    0x8(%ebp),%eax
80104e7e:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104e85:	8b 45 08             	mov    0x8(%ebp),%eax
80104e88:	89 04 24             	mov    %eax,(%esp)
80104e8b:	e8 9f fd ff ff       	call   80104c2f <wakeup>
  release(&lk->lk);
80104e90:	8b 45 08             	mov    0x8(%ebp),%eax
80104e93:	83 c0 04             	add    $0x4,%eax
80104e96:	89 04 24             	mov    %eax,(%esp)
80104e99:	e8 f0 00 00 00       	call   80104f8e <release>
}
80104e9e:	c9                   	leave  
80104e9f:	c3                   	ret    

80104ea0 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104ea0:	55                   	push   %ebp
80104ea1:	89 e5                	mov    %esp,%ebp
80104ea3:	83 ec 28             	sub    $0x28,%esp
  int r;
  
  acquire(&lk->lk);
80104ea6:	8b 45 08             	mov    0x8(%ebp),%eax
80104ea9:	83 c0 04             	add    $0x4,%eax
80104eac:	89 04 24             	mov    %eax,(%esp)
80104eaf:	e8 73 00 00 00       	call   80104f27 <acquire>
  r = lk->locked;
80104eb4:	8b 45 08             	mov    0x8(%ebp),%eax
80104eb7:	8b 00                	mov    (%eax),%eax
80104eb9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104ebc:	8b 45 08             	mov    0x8(%ebp),%eax
80104ebf:	83 c0 04             	add    $0x4,%eax
80104ec2:	89 04 24             	mov    %eax,(%esp)
80104ec5:	e8 c4 00 00 00       	call   80104f8e <release>
  return r;
80104eca:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104ecd:	c9                   	leave  
80104ece:	c3                   	ret    
	...

80104ed0 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104ed0:	55                   	push   %ebp
80104ed1:	89 e5                	mov    %esp,%ebp
80104ed3:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104ed6:	9c                   	pushf  
80104ed7:	58                   	pop    %eax
80104ed8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104edb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104ede:	c9                   	leave  
80104edf:	c3                   	ret    

80104ee0 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80104ee0:	55                   	push   %ebp
80104ee1:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104ee3:	fa                   	cli    
}
80104ee4:	5d                   	pop    %ebp
80104ee5:	c3                   	ret    

80104ee6 <sti>:

static inline void
sti(void)
{
80104ee6:	55                   	push   %ebp
80104ee7:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104ee9:	fb                   	sti    
}
80104eea:	5d                   	pop    %ebp
80104eeb:	c3                   	ret    

80104eec <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80104eec:	55                   	push   %ebp
80104eed:	89 e5                	mov    %esp,%ebp
80104eef:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104ef2:	8b 55 08             	mov    0x8(%ebp),%edx
80104ef5:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ef8:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104efb:	f0 87 02             	lock xchg %eax,(%edx)
80104efe:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80104f01:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104f04:	c9                   	leave  
80104f05:	c3                   	ret    

80104f06 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104f06:	55                   	push   %ebp
80104f07:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104f09:	8b 45 08             	mov    0x8(%ebp),%eax
80104f0c:	8b 55 0c             	mov    0xc(%ebp),%edx
80104f0f:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104f12:	8b 45 08             	mov    0x8(%ebp),%eax
80104f15:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104f1b:	8b 45 08             	mov    0x8(%ebp),%eax
80104f1e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104f25:	5d                   	pop    %ebp
80104f26:	c3                   	ret    

80104f27 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104f27:	55                   	push   %ebp
80104f28:	89 e5                	mov    %esp,%ebp
80104f2a:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104f2d:	e8 4a 01 00 00       	call   8010507c <pushcli>
  if(holding(lk))
80104f32:	8b 45 08             	mov    0x8(%ebp),%eax
80104f35:	89 04 24             	mov    %eax,(%esp)
80104f38:	e8 15 01 00 00       	call   80105052 <holding>
80104f3d:	85 c0                	test   %eax,%eax
80104f3f:	74 0c                	je     80104f4d <acquire+0x26>
    panic("acquire");
80104f41:	c7 04 24 54 89 10 80 	movl   $0x80108954,(%esp)
80104f48:	e8 07 b6 ff ff       	call   80100554 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104f4d:	90                   	nop
80104f4e:	8b 45 08             	mov    0x8(%ebp),%eax
80104f51:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80104f58:	00 
80104f59:	89 04 24             	mov    %eax,(%esp)
80104f5c:	e8 8b ff ff ff       	call   80104eec <xchg>
80104f61:	85 c0                	test   %eax,%eax
80104f63:	75 e9                	jne    80104f4e <acquire+0x27>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104f65:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80104f6a:	8b 45 08             	mov    0x8(%ebp),%eax
80104f6d:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104f74:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80104f77:	8b 45 08             	mov    0x8(%ebp),%eax
80104f7a:	83 c0 0c             	add    $0xc,%eax
80104f7d:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f81:	8d 45 08             	lea    0x8(%ebp),%eax
80104f84:	89 04 24             	mov    %eax,(%esp)
80104f87:	e8 4f 00 00 00       	call   80104fdb <getcallerpcs>
}
80104f8c:	c9                   	leave  
80104f8d:	c3                   	ret    

80104f8e <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104f8e:	55                   	push   %ebp
80104f8f:	89 e5                	mov    %esp,%ebp
80104f91:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80104f94:	8b 45 08             	mov    0x8(%ebp),%eax
80104f97:	89 04 24             	mov    %eax,(%esp)
80104f9a:	e8 b3 00 00 00       	call   80105052 <holding>
80104f9f:	85 c0                	test   %eax,%eax
80104fa1:	75 0c                	jne    80104faf <release+0x21>
    panic("release");
80104fa3:	c7 04 24 5c 89 10 80 	movl   $0x8010895c,(%esp)
80104faa:	e8 a5 b5 ff ff       	call   80100554 <panic>

  lk->pcs[0] = 0;
80104faf:	8b 45 08             	mov    0x8(%ebp),%eax
80104fb2:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104fb9:	8b 45 08             	mov    0x8(%ebp),%eax
80104fbc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104fc3:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104fc8:	8b 45 08             	mov    0x8(%ebp),%eax
80104fcb:	8b 55 08             	mov    0x8(%ebp),%edx
80104fce:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104fd4:	e8 f7 00 00 00       	call   801050d0 <popcli>
}
80104fd9:	c9                   	leave  
80104fda:	c3                   	ret    

80104fdb <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104fdb:	55                   	push   %ebp
80104fdc:	89 e5                	mov    %esp,%ebp
80104fde:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104fe1:	8b 45 08             	mov    0x8(%ebp),%eax
80104fe4:	83 e8 08             	sub    $0x8,%eax
80104fe7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104fea:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104ff1:	eb 37                	jmp    8010502a <getcallerpcs+0x4f>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104ff3:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104ff7:	74 37                	je     80105030 <getcallerpcs+0x55>
80104ff9:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105000:	76 2e                	jbe    80105030 <getcallerpcs+0x55>
80105002:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105006:	74 28                	je     80105030 <getcallerpcs+0x55>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105008:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010500b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105012:	8b 45 0c             	mov    0xc(%ebp),%eax
80105015:	01 c2                	add    %eax,%edx
80105017:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010501a:	8b 40 04             	mov    0x4(%eax),%eax
8010501d:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
8010501f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105022:	8b 00                	mov    (%eax),%eax
80105024:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80105027:	ff 45 f8             	incl   -0x8(%ebp)
8010502a:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010502e:	7e c3                	jle    80104ff3 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105030:	eb 18                	jmp    8010504a <getcallerpcs+0x6f>
    pcs[i] = 0;
80105032:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105035:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010503c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010503f:	01 d0                	add    %edx,%eax
80105041:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105047:	ff 45 f8             	incl   -0x8(%ebp)
8010504a:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010504e:	7e e2                	jle    80105032 <getcallerpcs+0x57>
    pcs[i] = 0;
}
80105050:	c9                   	leave  
80105051:	c3                   	ret    

80105052 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105052:	55                   	push   %ebp
80105053:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80105055:	8b 45 08             	mov    0x8(%ebp),%eax
80105058:	8b 00                	mov    (%eax),%eax
8010505a:	85 c0                	test   %eax,%eax
8010505c:	74 17                	je     80105075 <holding+0x23>
8010505e:	8b 45 08             	mov    0x8(%ebp),%eax
80105061:	8b 50 08             	mov    0x8(%eax),%edx
80105064:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010506a:	39 c2                	cmp    %eax,%edx
8010506c:	75 07                	jne    80105075 <holding+0x23>
8010506e:	b8 01 00 00 00       	mov    $0x1,%eax
80105073:	eb 05                	jmp    8010507a <holding+0x28>
80105075:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010507a:	5d                   	pop    %ebp
8010507b:	c3                   	ret    

8010507c <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
8010507c:	55                   	push   %ebp
8010507d:	89 e5                	mov    %esp,%ebp
8010507f:	83 ec 10             	sub    $0x10,%esp
  int eflags;

  eflags = readeflags();
80105082:	e8 49 fe ff ff       	call   80104ed0 <readeflags>
80105087:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
8010508a:	e8 51 fe ff ff       	call   80104ee0 <cli>
  if(cpu->ncli == 0)
8010508f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105095:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010509b:	85 c0                	test   %eax,%eax
8010509d:	75 15                	jne    801050b4 <pushcli+0x38>
    cpu->intena = eflags & FL_IF;
8010509f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801050a5:	8b 55 fc             	mov    -0x4(%ebp),%edx
801050a8:	81 e2 00 02 00 00    	and    $0x200,%edx
801050ae:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
  cpu->ncli += 1;
801050b4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801050ba:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801050c1:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
801050c7:	42                   	inc    %edx
801050c8:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
}
801050ce:	c9                   	leave  
801050cf:	c3                   	ret    

801050d0 <popcli>:

void
popcli(void)
{
801050d0:	55                   	push   %ebp
801050d1:	89 e5                	mov    %esp,%ebp
801050d3:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
801050d6:	e8 f5 fd ff ff       	call   80104ed0 <readeflags>
801050db:	25 00 02 00 00       	and    $0x200,%eax
801050e0:	85 c0                	test   %eax,%eax
801050e2:	74 0c                	je     801050f0 <popcli+0x20>
    panic("popcli - interruptible");
801050e4:	c7 04 24 64 89 10 80 	movl   $0x80108964,(%esp)
801050eb:	e8 64 b4 ff ff       	call   80100554 <panic>
  if(--cpu->ncli < 0)
801050f0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801050f6:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
801050fc:	4a                   	dec    %edx
801050fd:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105103:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105109:	85 c0                	test   %eax,%eax
8010510b:	79 0c                	jns    80105119 <popcli+0x49>
    panic("popcli");
8010510d:	c7 04 24 7b 89 10 80 	movl   $0x8010897b,(%esp)
80105114:	e8 3b b4 ff ff       	call   80100554 <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105119:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010511f:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105125:	85 c0                	test   %eax,%eax
80105127:	75 15                	jne    8010513e <popcli+0x6e>
80105129:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010512f:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105135:	85 c0                	test   %eax,%eax
80105137:	74 05                	je     8010513e <popcli+0x6e>
    sti();
80105139:	e8 a8 fd ff ff       	call   80104ee6 <sti>
}
8010513e:	c9                   	leave  
8010513f:	c3                   	ret    

80105140 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105140:	55                   	push   %ebp
80105141:	89 e5                	mov    %esp,%ebp
80105143:	57                   	push   %edi
80105144:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105145:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105148:	8b 55 10             	mov    0x10(%ebp),%edx
8010514b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010514e:	89 cb                	mov    %ecx,%ebx
80105150:	89 df                	mov    %ebx,%edi
80105152:	89 d1                	mov    %edx,%ecx
80105154:	fc                   	cld    
80105155:	f3 aa                	rep stos %al,%es:(%edi)
80105157:	89 ca                	mov    %ecx,%edx
80105159:	89 fb                	mov    %edi,%ebx
8010515b:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010515e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105161:	5b                   	pop    %ebx
80105162:	5f                   	pop    %edi
80105163:	5d                   	pop    %ebp
80105164:	c3                   	ret    

80105165 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105165:	55                   	push   %ebp
80105166:	89 e5                	mov    %esp,%ebp
80105168:	57                   	push   %edi
80105169:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
8010516a:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010516d:	8b 55 10             	mov    0x10(%ebp),%edx
80105170:	8b 45 0c             	mov    0xc(%ebp),%eax
80105173:	89 cb                	mov    %ecx,%ebx
80105175:	89 df                	mov    %ebx,%edi
80105177:	89 d1                	mov    %edx,%ecx
80105179:	fc                   	cld    
8010517a:	f3 ab                	rep stos %eax,%es:(%edi)
8010517c:	89 ca                	mov    %ecx,%edx
8010517e:	89 fb                	mov    %edi,%ebx
80105180:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105183:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105186:	5b                   	pop    %ebx
80105187:	5f                   	pop    %edi
80105188:	5d                   	pop    %ebp
80105189:	c3                   	ret    

8010518a <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
8010518a:	55                   	push   %ebp
8010518b:	89 e5                	mov    %esp,%ebp
8010518d:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
80105190:	8b 45 08             	mov    0x8(%ebp),%eax
80105193:	83 e0 03             	and    $0x3,%eax
80105196:	85 c0                	test   %eax,%eax
80105198:	75 49                	jne    801051e3 <memset+0x59>
8010519a:	8b 45 10             	mov    0x10(%ebp),%eax
8010519d:	83 e0 03             	and    $0x3,%eax
801051a0:	85 c0                	test   %eax,%eax
801051a2:	75 3f                	jne    801051e3 <memset+0x59>
    c &= 0xFF;
801051a4:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801051ab:	8b 45 10             	mov    0x10(%ebp),%eax
801051ae:	c1 e8 02             	shr    $0x2,%eax
801051b1:	89 c2                	mov    %eax,%edx
801051b3:	8b 45 0c             	mov    0xc(%ebp),%eax
801051b6:	c1 e0 18             	shl    $0x18,%eax
801051b9:	89 c1                	mov    %eax,%ecx
801051bb:	8b 45 0c             	mov    0xc(%ebp),%eax
801051be:	c1 e0 10             	shl    $0x10,%eax
801051c1:	09 c1                	or     %eax,%ecx
801051c3:	8b 45 0c             	mov    0xc(%ebp),%eax
801051c6:	c1 e0 08             	shl    $0x8,%eax
801051c9:	09 c8                	or     %ecx,%eax
801051cb:	0b 45 0c             	or     0xc(%ebp),%eax
801051ce:	89 54 24 08          	mov    %edx,0x8(%esp)
801051d2:	89 44 24 04          	mov    %eax,0x4(%esp)
801051d6:	8b 45 08             	mov    0x8(%ebp),%eax
801051d9:	89 04 24             	mov    %eax,(%esp)
801051dc:	e8 84 ff ff ff       	call   80105165 <stosl>
801051e1:	eb 19                	jmp    801051fc <memset+0x72>
  } else
    stosb(dst, c, n);
801051e3:	8b 45 10             	mov    0x10(%ebp),%eax
801051e6:	89 44 24 08          	mov    %eax,0x8(%esp)
801051ea:	8b 45 0c             	mov    0xc(%ebp),%eax
801051ed:	89 44 24 04          	mov    %eax,0x4(%esp)
801051f1:	8b 45 08             	mov    0x8(%ebp),%eax
801051f4:	89 04 24             	mov    %eax,(%esp)
801051f7:	e8 44 ff ff ff       	call   80105140 <stosb>
  return dst;
801051fc:	8b 45 08             	mov    0x8(%ebp),%eax
}
801051ff:	c9                   	leave  
80105200:	c3                   	ret    

80105201 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105201:	55                   	push   %ebp
80105202:	89 e5                	mov    %esp,%ebp
80105204:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80105207:	8b 45 08             	mov    0x8(%ebp),%eax
8010520a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
8010520d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105210:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105213:	eb 2a                	jmp    8010523f <memcmp+0x3e>
    if(*s1 != *s2)
80105215:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105218:	8a 10                	mov    (%eax),%dl
8010521a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010521d:	8a 00                	mov    (%eax),%al
8010521f:	38 c2                	cmp    %al,%dl
80105221:	74 16                	je     80105239 <memcmp+0x38>
      return *s1 - *s2;
80105223:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105226:	8a 00                	mov    (%eax),%al
80105228:	0f b6 d0             	movzbl %al,%edx
8010522b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010522e:	8a 00                	mov    (%eax),%al
80105230:	0f b6 c0             	movzbl %al,%eax
80105233:	29 c2                	sub    %eax,%edx
80105235:	89 d0                	mov    %edx,%eax
80105237:	eb 18                	jmp    80105251 <memcmp+0x50>
    s1++, s2++;
80105239:	ff 45 fc             	incl   -0x4(%ebp)
8010523c:	ff 45 f8             	incl   -0x8(%ebp)
{
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
8010523f:	8b 45 10             	mov    0x10(%ebp),%eax
80105242:	8d 50 ff             	lea    -0x1(%eax),%edx
80105245:	89 55 10             	mov    %edx,0x10(%ebp)
80105248:	85 c0                	test   %eax,%eax
8010524a:	75 c9                	jne    80105215 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
8010524c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105251:	c9                   	leave  
80105252:	c3                   	ret    

80105253 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105253:	55                   	push   %ebp
80105254:	89 e5                	mov    %esp,%ebp
80105256:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105259:	8b 45 0c             	mov    0xc(%ebp),%eax
8010525c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
8010525f:	8b 45 08             	mov    0x8(%ebp),%eax
80105262:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105265:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105268:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010526b:	73 3a                	jae    801052a7 <memmove+0x54>
8010526d:	8b 45 10             	mov    0x10(%ebp),%eax
80105270:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105273:	01 d0                	add    %edx,%eax
80105275:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105278:	76 2d                	jbe    801052a7 <memmove+0x54>
    s += n;
8010527a:	8b 45 10             	mov    0x10(%ebp),%eax
8010527d:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105280:	8b 45 10             	mov    0x10(%ebp),%eax
80105283:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105286:	eb 10                	jmp    80105298 <memmove+0x45>
      *--d = *--s;
80105288:	ff 4d f8             	decl   -0x8(%ebp)
8010528b:	ff 4d fc             	decl   -0x4(%ebp)
8010528e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105291:	8a 10                	mov    (%eax),%dl
80105293:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105296:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105298:	8b 45 10             	mov    0x10(%ebp),%eax
8010529b:	8d 50 ff             	lea    -0x1(%eax),%edx
8010529e:	89 55 10             	mov    %edx,0x10(%ebp)
801052a1:	85 c0                	test   %eax,%eax
801052a3:	75 e3                	jne    80105288 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
801052a5:	eb 25                	jmp    801052cc <memmove+0x79>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801052a7:	eb 16                	jmp    801052bf <memmove+0x6c>
      *d++ = *s++;
801052a9:	8b 45 f8             	mov    -0x8(%ebp),%eax
801052ac:	8d 50 01             	lea    0x1(%eax),%edx
801052af:	89 55 f8             	mov    %edx,-0x8(%ebp)
801052b2:	8b 55 fc             	mov    -0x4(%ebp),%edx
801052b5:	8d 4a 01             	lea    0x1(%edx),%ecx
801052b8:	89 4d fc             	mov    %ecx,-0x4(%ebp)
801052bb:	8a 12                	mov    (%edx),%dl
801052bd:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801052bf:	8b 45 10             	mov    0x10(%ebp),%eax
801052c2:	8d 50 ff             	lea    -0x1(%eax),%edx
801052c5:	89 55 10             	mov    %edx,0x10(%ebp)
801052c8:	85 c0                	test   %eax,%eax
801052ca:	75 dd                	jne    801052a9 <memmove+0x56>
      *d++ = *s++;

  return dst;
801052cc:	8b 45 08             	mov    0x8(%ebp),%eax
}
801052cf:	c9                   	leave  
801052d0:	c3                   	ret    

801052d1 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801052d1:	55                   	push   %ebp
801052d2:	89 e5                	mov    %esp,%ebp
801052d4:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
801052d7:	8b 45 10             	mov    0x10(%ebp),%eax
801052da:	89 44 24 08          	mov    %eax,0x8(%esp)
801052de:	8b 45 0c             	mov    0xc(%ebp),%eax
801052e1:	89 44 24 04          	mov    %eax,0x4(%esp)
801052e5:	8b 45 08             	mov    0x8(%ebp),%eax
801052e8:	89 04 24             	mov    %eax,(%esp)
801052eb:	e8 63 ff ff ff       	call   80105253 <memmove>
}
801052f0:	c9                   	leave  
801052f1:	c3                   	ret    

801052f2 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801052f2:	55                   	push   %ebp
801052f3:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801052f5:	eb 09                	jmp    80105300 <strncmp+0xe>
    n--, p++, q++;
801052f7:	ff 4d 10             	decl   0x10(%ebp)
801052fa:	ff 45 08             	incl   0x8(%ebp)
801052fd:	ff 45 0c             	incl   0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105300:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105304:	74 17                	je     8010531d <strncmp+0x2b>
80105306:	8b 45 08             	mov    0x8(%ebp),%eax
80105309:	8a 00                	mov    (%eax),%al
8010530b:	84 c0                	test   %al,%al
8010530d:	74 0e                	je     8010531d <strncmp+0x2b>
8010530f:	8b 45 08             	mov    0x8(%ebp),%eax
80105312:	8a 10                	mov    (%eax),%dl
80105314:	8b 45 0c             	mov    0xc(%ebp),%eax
80105317:	8a 00                	mov    (%eax),%al
80105319:	38 c2                	cmp    %al,%dl
8010531b:	74 da                	je     801052f7 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
8010531d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105321:	75 07                	jne    8010532a <strncmp+0x38>
    return 0;
80105323:	b8 00 00 00 00       	mov    $0x0,%eax
80105328:	eb 14                	jmp    8010533e <strncmp+0x4c>
  return (uchar)*p - (uchar)*q;
8010532a:	8b 45 08             	mov    0x8(%ebp),%eax
8010532d:	8a 00                	mov    (%eax),%al
8010532f:	0f b6 d0             	movzbl %al,%edx
80105332:	8b 45 0c             	mov    0xc(%ebp),%eax
80105335:	8a 00                	mov    (%eax),%al
80105337:	0f b6 c0             	movzbl %al,%eax
8010533a:	29 c2                	sub    %eax,%edx
8010533c:	89 d0                	mov    %edx,%eax
}
8010533e:	5d                   	pop    %ebp
8010533f:	c3                   	ret    

80105340 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105340:	55                   	push   %ebp
80105341:	89 e5                	mov    %esp,%ebp
80105343:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105346:	8b 45 08             	mov    0x8(%ebp),%eax
80105349:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
8010534c:	90                   	nop
8010534d:	8b 45 10             	mov    0x10(%ebp),%eax
80105350:	8d 50 ff             	lea    -0x1(%eax),%edx
80105353:	89 55 10             	mov    %edx,0x10(%ebp)
80105356:	85 c0                	test   %eax,%eax
80105358:	7e 1c                	jle    80105376 <strncpy+0x36>
8010535a:	8b 45 08             	mov    0x8(%ebp),%eax
8010535d:	8d 50 01             	lea    0x1(%eax),%edx
80105360:	89 55 08             	mov    %edx,0x8(%ebp)
80105363:	8b 55 0c             	mov    0xc(%ebp),%edx
80105366:	8d 4a 01             	lea    0x1(%edx),%ecx
80105369:	89 4d 0c             	mov    %ecx,0xc(%ebp)
8010536c:	8a 12                	mov    (%edx),%dl
8010536e:	88 10                	mov    %dl,(%eax)
80105370:	8a 00                	mov    (%eax),%al
80105372:	84 c0                	test   %al,%al
80105374:	75 d7                	jne    8010534d <strncpy+0xd>
    ;
  while(n-- > 0)
80105376:	eb 0c                	jmp    80105384 <strncpy+0x44>
    *s++ = 0;
80105378:	8b 45 08             	mov    0x8(%ebp),%eax
8010537b:	8d 50 01             	lea    0x1(%eax),%edx
8010537e:	89 55 08             	mov    %edx,0x8(%ebp)
80105381:	c6 00 00             	movb   $0x0,(%eax)
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105384:	8b 45 10             	mov    0x10(%ebp),%eax
80105387:	8d 50 ff             	lea    -0x1(%eax),%edx
8010538a:	89 55 10             	mov    %edx,0x10(%ebp)
8010538d:	85 c0                	test   %eax,%eax
8010538f:	7f e7                	jg     80105378 <strncpy+0x38>
    *s++ = 0;
  return os;
80105391:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105394:	c9                   	leave  
80105395:	c3                   	ret    

80105396 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105396:	55                   	push   %ebp
80105397:	89 e5                	mov    %esp,%ebp
80105399:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
8010539c:	8b 45 08             	mov    0x8(%ebp),%eax
8010539f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801053a2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801053a6:	7f 05                	jg     801053ad <safestrcpy+0x17>
    return os;
801053a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053ab:	eb 2e                	jmp    801053db <safestrcpy+0x45>
  while(--n > 0 && (*s++ = *t++) != 0)
801053ad:	ff 4d 10             	decl   0x10(%ebp)
801053b0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801053b4:	7e 1c                	jle    801053d2 <safestrcpy+0x3c>
801053b6:	8b 45 08             	mov    0x8(%ebp),%eax
801053b9:	8d 50 01             	lea    0x1(%eax),%edx
801053bc:	89 55 08             	mov    %edx,0x8(%ebp)
801053bf:	8b 55 0c             	mov    0xc(%ebp),%edx
801053c2:	8d 4a 01             	lea    0x1(%edx),%ecx
801053c5:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801053c8:	8a 12                	mov    (%edx),%dl
801053ca:	88 10                	mov    %dl,(%eax)
801053cc:	8a 00                	mov    (%eax),%al
801053ce:	84 c0                	test   %al,%al
801053d0:	75 db                	jne    801053ad <safestrcpy+0x17>
    ;
  *s = 0;
801053d2:	8b 45 08             	mov    0x8(%ebp),%eax
801053d5:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801053d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801053db:	c9                   	leave  
801053dc:	c3                   	ret    

801053dd <strlen>:

int
strlen(const char *s)
{
801053dd:	55                   	push   %ebp
801053de:	89 e5                	mov    %esp,%ebp
801053e0:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801053e3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801053ea:	eb 03                	jmp    801053ef <strlen+0x12>
801053ec:	ff 45 fc             	incl   -0x4(%ebp)
801053ef:	8b 55 fc             	mov    -0x4(%ebp),%edx
801053f2:	8b 45 08             	mov    0x8(%ebp),%eax
801053f5:	01 d0                	add    %edx,%eax
801053f7:	8a 00                	mov    (%eax),%al
801053f9:	84 c0                	test   %al,%al
801053fb:	75 ef                	jne    801053ec <strlen+0xf>
    ;
  return n;
801053fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105400:	c9                   	leave  
80105401:	c3                   	ret    
	...

80105404 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105404:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105408:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
8010540c:	55                   	push   %ebp
  pushl %ebx
8010540d:	53                   	push   %ebx
  pushl %esi
8010540e:	56                   	push   %esi
  pushl %edi
8010540f:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105410:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105412:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105414:	5f                   	pop    %edi
  popl %esi
80105415:	5e                   	pop    %esi
  popl %ebx
80105416:	5b                   	pop    %ebx
  popl %ebp
80105417:	5d                   	pop    %ebp
  ret
80105418:	c3                   	ret    
80105419:	00 00                	add    %al,(%eax)
	...

8010541c <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
8010541c:	55                   	push   %ebp
8010541d:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
8010541f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105425:	8b 00                	mov    (%eax),%eax
80105427:	3b 45 08             	cmp    0x8(%ebp),%eax
8010542a:	76 12                	jbe    8010543e <fetchint+0x22>
8010542c:	8b 45 08             	mov    0x8(%ebp),%eax
8010542f:	8d 50 04             	lea    0x4(%eax),%edx
80105432:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105438:	8b 00                	mov    (%eax),%eax
8010543a:	39 c2                	cmp    %eax,%edx
8010543c:	76 07                	jbe    80105445 <fetchint+0x29>
    return -1;
8010543e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105443:	eb 0f                	jmp    80105454 <fetchint+0x38>
  *ip = *(int*)(addr);
80105445:	8b 45 08             	mov    0x8(%ebp),%eax
80105448:	8b 10                	mov    (%eax),%edx
8010544a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010544d:	89 10                	mov    %edx,(%eax)
  return 0;
8010544f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105454:	5d                   	pop    %ebp
80105455:	c3                   	ret    

80105456 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105456:	55                   	push   %ebp
80105457:	89 e5                	mov    %esp,%ebp
80105459:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
8010545c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105462:	8b 00                	mov    (%eax),%eax
80105464:	3b 45 08             	cmp    0x8(%ebp),%eax
80105467:	77 07                	ja     80105470 <fetchstr+0x1a>
    return -1;
80105469:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010546e:	eb 44                	jmp    801054b4 <fetchstr+0x5e>
  *pp = (char*)addr;
80105470:	8b 55 08             	mov    0x8(%ebp),%edx
80105473:	8b 45 0c             	mov    0xc(%ebp),%eax
80105476:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80105478:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010547e:	8b 00                	mov    (%eax),%eax
80105480:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80105483:	8b 45 0c             	mov    0xc(%ebp),%eax
80105486:	8b 00                	mov    (%eax),%eax
80105488:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010548b:	eb 1a                	jmp    801054a7 <fetchstr+0x51>
    if(*s == 0)
8010548d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105490:	8a 00                	mov    (%eax),%al
80105492:	84 c0                	test   %al,%al
80105494:	75 0e                	jne    801054a4 <fetchstr+0x4e>
      return s - *pp;
80105496:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105499:	8b 45 0c             	mov    0xc(%ebp),%eax
8010549c:	8b 00                	mov    (%eax),%eax
8010549e:	29 c2                	sub    %eax,%edx
801054a0:	89 d0                	mov    %edx,%eax
801054a2:	eb 10                	jmp    801054b4 <fetchstr+0x5e>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
801054a4:	ff 45 fc             	incl   -0x4(%ebp)
801054a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054aa:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801054ad:	72 de                	jb     8010548d <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
801054af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801054b4:	c9                   	leave  
801054b5:	c3                   	ret    

801054b6 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801054b6:	55                   	push   %ebp
801054b7:	89 e5                	mov    %esp,%ebp
801054b9:	83 ec 08             	sub    $0x8,%esp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
801054bc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054c2:	8b 40 18             	mov    0x18(%eax),%eax
801054c5:	8b 50 44             	mov    0x44(%eax),%edx
801054c8:	8b 45 08             	mov    0x8(%ebp),%eax
801054cb:	c1 e0 02             	shl    $0x2,%eax
801054ce:	01 d0                	add    %edx,%eax
801054d0:	8d 50 04             	lea    0x4(%eax),%edx
801054d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801054d6:	89 44 24 04          	mov    %eax,0x4(%esp)
801054da:	89 14 24             	mov    %edx,(%esp)
801054dd:	e8 3a ff ff ff       	call   8010541c <fetchint>
}
801054e2:	c9                   	leave  
801054e3:	c3                   	ret    

801054e4 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801054e4:	55                   	push   %ebp
801054e5:	89 e5                	mov    %esp,%ebp
801054e7:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(argint(n, &i) < 0)
801054ea:	8d 45 fc             	lea    -0x4(%ebp),%eax
801054ed:	89 44 24 04          	mov    %eax,0x4(%esp)
801054f1:	8b 45 08             	mov    0x8(%ebp),%eax
801054f4:	89 04 24             	mov    %eax,(%esp)
801054f7:	e8 ba ff ff ff       	call   801054b6 <argint>
801054fc:	85 c0                	test   %eax,%eax
801054fe:	79 07                	jns    80105507 <argptr+0x23>
    return -1;
80105500:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105505:	eb 43                	jmp    8010554a <argptr+0x66>
  if(size < 0 || (uint)i >= proc->sz || (uint)i+size > proc->sz)
80105507:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010550b:	78 27                	js     80105534 <argptr+0x50>
8010550d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105510:	89 c2                	mov    %eax,%edx
80105512:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105518:	8b 00                	mov    (%eax),%eax
8010551a:	39 c2                	cmp    %eax,%edx
8010551c:	73 16                	jae    80105534 <argptr+0x50>
8010551e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105521:	89 c2                	mov    %eax,%edx
80105523:	8b 45 10             	mov    0x10(%ebp),%eax
80105526:	01 c2                	add    %eax,%edx
80105528:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010552e:	8b 00                	mov    (%eax),%eax
80105530:	39 c2                	cmp    %eax,%edx
80105532:	76 07                	jbe    8010553b <argptr+0x57>
    return -1;
80105534:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105539:	eb 0f                	jmp    8010554a <argptr+0x66>
  *pp = (char*)i;
8010553b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010553e:	89 c2                	mov    %eax,%edx
80105540:	8b 45 0c             	mov    0xc(%ebp),%eax
80105543:	89 10                	mov    %edx,(%eax)
  return 0;
80105545:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010554a:	c9                   	leave  
8010554b:	c3                   	ret    

8010554c <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
8010554c:	55                   	push   %ebp
8010554d:	89 e5                	mov    %esp,%ebp
8010554f:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105552:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105555:	89 44 24 04          	mov    %eax,0x4(%esp)
80105559:	8b 45 08             	mov    0x8(%ebp),%eax
8010555c:	89 04 24             	mov    %eax,(%esp)
8010555f:	e8 52 ff ff ff       	call   801054b6 <argint>
80105564:	85 c0                	test   %eax,%eax
80105566:	79 07                	jns    8010556f <argstr+0x23>
    return -1;
80105568:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010556d:	eb 12                	jmp    80105581 <argstr+0x35>
  return fetchstr(addr, pp);
8010556f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105572:	8b 55 0c             	mov    0xc(%ebp),%edx
80105575:	89 54 24 04          	mov    %edx,0x4(%esp)
80105579:	89 04 24             	mov    %eax,(%esp)
8010557c:	e8 d5 fe ff ff       	call   80105456 <fetchstr>
}
80105581:	c9                   	leave  
80105582:	c3                   	ret    

80105583 <syscall>:
[SYS_pipe_count]   sys_pipe_count,
};

void
syscall(void)
{
80105583:	55                   	push   %ebp
80105584:	89 e5                	mov    %esp,%ebp
80105586:	53                   	push   %ebx
80105587:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
8010558a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105590:	8b 40 18             	mov    0x18(%eax),%eax
80105593:	8b 40 1c             	mov    0x1c(%eax),%eax
80105596:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105599:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010559d:	7e 30                	jle    801055cf <syscall+0x4c>
8010559f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055a2:	83 f8 18             	cmp    $0x18,%eax
801055a5:	77 28                	ja     801055cf <syscall+0x4c>
801055a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055aa:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
801055b1:	85 c0                	test   %eax,%eax
801055b3:	74 1a                	je     801055cf <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
801055b5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055bb:	8b 58 18             	mov    0x18(%eax),%ebx
801055be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055c1:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
801055c8:	ff d0                	call   *%eax
801055ca:	89 43 1c             	mov    %eax,0x1c(%ebx)
801055cd:	eb 3d                	jmp    8010560c <syscall+0x89>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
801055cf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055d5:	8d 48 6c             	lea    0x6c(%eax),%ecx
801055d8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
801055de:	8b 40 10             	mov    0x10(%eax),%eax
801055e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801055e4:	89 54 24 0c          	mov    %edx,0xc(%esp)
801055e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801055ec:	89 44 24 04          	mov    %eax,0x4(%esp)
801055f0:	c7 04 24 82 89 10 80 	movl   $0x80108982,(%esp)
801055f7:	e8 c5 ad ff ff       	call   801003c1 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
801055fc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105602:	8b 40 18             	mov    0x18(%eax),%eax
80105605:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
8010560c:	83 c4 24             	add    $0x24,%esp
8010560f:	5b                   	pop    %ebx
80105610:	5d                   	pop    %ebp
80105611:	c3                   	ret    
	...

80105614 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105614:	55                   	push   %ebp
80105615:	89 e5                	mov    %esp,%ebp
80105617:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010561a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010561d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105621:	8b 45 08             	mov    0x8(%ebp),%eax
80105624:	89 04 24             	mov    %eax,(%esp)
80105627:	e8 8a fe ff ff       	call   801054b6 <argint>
8010562c:	85 c0                	test   %eax,%eax
8010562e:	79 07                	jns    80105637 <argfd+0x23>
    return -1;
80105630:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105635:	eb 50                	jmp    80105687 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80105637:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010563a:	85 c0                	test   %eax,%eax
8010563c:	78 21                	js     8010565f <argfd+0x4b>
8010563e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105641:	83 f8 0f             	cmp    $0xf,%eax
80105644:	7f 19                	jg     8010565f <argfd+0x4b>
80105646:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010564c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010564f:	83 c2 08             	add    $0x8,%edx
80105652:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105656:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105659:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010565d:	75 07                	jne    80105666 <argfd+0x52>
    return -1;
8010565f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105664:	eb 21                	jmp    80105687 <argfd+0x73>
  if(pfd)
80105666:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010566a:	74 08                	je     80105674 <argfd+0x60>
    *pfd = fd;
8010566c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010566f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105672:	89 10                	mov    %edx,(%eax)
  if(pf)
80105674:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105678:	74 08                	je     80105682 <argfd+0x6e>
    *pf = f;
8010567a:	8b 45 10             	mov    0x10(%ebp),%eax
8010567d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105680:	89 10                	mov    %edx,(%eax)
  return 0;
80105682:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105687:	c9                   	leave  
80105688:	c3                   	ret    

80105689 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105689:	55                   	push   %ebp
8010568a:	89 e5                	mov    %esp,%ebp
8010568c:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
8010568f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105696:	eb 2f                	jmp    801056c7 <fdalloc+0x3e>
    if(proc->ofile[fd] == 0){
80105698:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010569e:	8b 55 fc             	mov    -0x4(%ebp),%edx
801056a1:	83 c2 08             	add    $0x8,%edx
801056a4:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801056a8:	85 c0                	test   %eax,%eax
801056aa:	75 18                	jne    801056c4 <fdalloc+0x3b>
      proc->ofile[fd] = f;
801056ac:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056b2:	8b 55 fc             	mov    -0x4(%ebp),%edx
801056b5:	8d 4a 08             	lea    0x8(%edx),%ecx
801056b8:	8b 55 08             	mov    0x8(%ebp),%edx
801056bb:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801056bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056c2:	eb 0e                	jmp    801056d2 <fdalloc+0x49>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801056c4:	ff 45 fc             	incl   -0x4(%ebp)
801056c7:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
801056cb:	7e cb                	jle    80105698 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
801056cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801056d2:	c9                   	leave  
801056d3:	c3                   	ret    

801056d4 <sys_dup>:

int
sys_dup(void)
{
801056d4:	55                   	push   %ebp
801056d5:	89 e5                	mov    %esp,%ebp
801056d7:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
801056da:	8d 45 f0             	lea    -0x10(%ebp),%eax
801056dd:	89 44 24 08          	mov    %eax,0x8(%esp)
801056e1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801056e8:	00 
801056e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801056f0:	e8 1f ff ff ff       	call   80105614 <argfd>
801056f5:	85 c0                	test   %eax,%eax
801056f7:	79 07                	jns    80105700 <sys_dup+0x2c>
    return -1;
801056f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056fe:	eb 29                	jmp    80105729 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105700:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105703:	89 04 24             	mov    %eax,(%esp)
80105706:	e8 7e ff ff ff       	call   80105689 <fdalloc>
8010570b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010570e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105712:	79 07                	jns    8010571b <sys_dup+0x47>
    return -1;
80105714:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105719:	eb 0e                	jmp    80105729 <sys_dup+0x55>
  filedup(f);
8010571b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010571e:	89 04 24             	mov    %eax,(%esp)
80105721:	e8 96 b8 ff ff       	call   80100fbc <filedup>
  return fd;
80105726:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105729:	c9                   	leave  
8010572a:	c3                   	ret    

8010572b <sys_read>:

int
sys_read(void)
{
8010572b:	55                   	push   %ebp
8010572c:	89 e5                	mov    %esp,%ebp
8010572e:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105731:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105734:	89 44 24 08          	mov    %eax,0x8(%esp)
80105738:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010573f:	00 
80105740:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105747:	e8 c8 fe ff ff       	call   80105614 <argfd>
8010574c:	85 c0                	test   %eax,%eax
8010574e:	78 35                	js     80105785 <sys_read+0x5a>
80105750:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105753:	89 44 24 04          	mov    %eax,0x4(%esp)
80105757:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010575e:	e8 53 fd ff ff       	call   801054b6 <argint>
80105763:	85 c0                	test   %eax,%eax
80105765:	78 1e                	js     80105785 <sys_read+0x5a>
80105767:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010576a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010576e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105771:	89 44 24 04          	mov    %eax,0x4(%esp)
80105775:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010577c:	e8 63 fd ff ff       	call   801054e4 <argptr>
80105781:	85 c0                	test   %eax,%eax
80105783:	79 07                	jns    8010578c <sys_read+0x61>
    return -1;
80105785:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010578a:	eb 19                	jmp    801057a5 <sys_read+0x7a>
  return fileread(f, p, n);
8010578c:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010578f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105792:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105795:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105799:	89 54 24 04          	mov    %edx,0x4(%esp)
8010579d:	89 04 24             	mov    %eax,(%esp)
801057a0:	e8 78 b9 ff ff       	call   8010111d <fileread>
}
801057a5:	c9                   	leave  
801057a6:	c3                   	ret    

801057a7 <sys_write>:

int
sys_write(void)
{
801057a7:	55                   	push   %ebp
801057a8:	89 e5                	mov    %esp,%ebp
801057aa:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801057ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
801057b0:	89 44 24 08          	mov    %eax,0x8(%esp)
801057b4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801057bb:	00 
801057bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801057c3:	e8 4c fe ff ff       	call   80105614 <argfd>
801057c8:	85 c0                	test   %eax,%eax
801057ca:	78 35                	js     80105801 <sys_write+0x5a>
801057cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801057cf:	89 44 24 04          	mov    %eax,0x4(%esp)
801057d3:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801057da:	e8 d7 fc ff ff       	call   801054b6 <argint>
801057df:	85 c0                	test   %eax,%eax
801057e1:	78 1e                	js     80105801 <sys_write+0x5a>
801057e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057e6:	89 44 24 08          	mov    %eax,0x8(%esp)
801057ea:	8d 45 ec             	lea    -0x14(%ebp),%eax
801057ed:	89 44 24 04          	mov    %eax,0x4(%esp)
801057f1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801057f8:	e8 e7 fc ff ff       	call   801054e4 <argptr>
801057fd:	85 c0                	test   %eax,%eax
801057ff:	79 07                	jns    80105808 <sys_write+0x61>
    return -1;
80105801:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105806:	eb 19                	jmp    80105821 <sys_write+0x7a>
  return filewrite(f, p, n);
80105808:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010580b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010580e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105811:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105815:	89 54 24 04          	mov    %edx,0x4(%esp)
80105819:	89 04 24             	mov    %eax,(%esp)
8010581c:	e8 b7 b9 ff ff       	call   801011d8 <filewrite>
}
80105821:	c9                   	leave  
80105822:	c3                   	ret    

80105823 <sys_close>:

int
sys_close(void)
{
80105823:	55                   	push   %ebp
80105824:	89 e5                	mov    %esp,%ebp
80105826:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105829:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010582c:	89 44 24 08          	mov    %eax,0x8(%esp)
80105830:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105833:	89 44 24 04          	mov    %eax,0x4(%esp)
80105837:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010583e:	e8 d1 fd ff ff       	call   80105614 <argfd>
80105843:	85 c0                	test   %eax,%eax
80105845:	79 07                	jns    8010584e <sys_close+0x2b>
    return -1;
80105847:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010584c:	eb 24                	jmp    80105872 <sys_close+0x4f>
  proc->ofile[fd] = 0;
8010584e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105854:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105857:	83 c2 08             	add    $0x8,%edx
8010585a:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105861:	00 
  fileclose(f);
80105862:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105865:	89 04 24             	mov    %eax,(%esp)
80105868:	e8 97 b7 ff ff       	call   80101004 <fileclose>
  return 0;
8010586d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105872:	c9                   	leave  
80105873:	c3                   	ret    

80105874 <sys_fstat>:

int
sys_fstat(void)
{
80105874:	55                   	push   %ebp
80105875:	89 e5                	mov    %esp,%ebp
80105877:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010587a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010587d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105881:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105888:	00 
80105889:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105890:	e8 7f fd ff ff       	call   80105614 <argfd>
80105895:	85 c0                	test   %eax,%eax
80105897:	78 1f                	js     801058b8 <sys_fstat+0x44>
80105899:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
801058a0:	00 
801058a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801058a8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801058af:	e8 30 fc ff ff       	call   801054e4 <argptr>
801058b4:	85 c0                	test   %eax,%eax
801058b6:	79 07                	jns    801058bf <sys_fstat+0x4b>
    return -1;
801058b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058bd:	eb 12                	jmp    801058d1 <sys_fstat+0x5d>
  return filestat(f, st);
801058bf:	8b 55 f0             	mov    -0x10(%ebp),%edx
801058c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058c5:	89 54 24 04          	mov    %edx,0x4(%esp)
801058c9:	89 04 24             	mov    %eax,(%esp)
801058cc:	e8 fd b7 ff ff       	call   801010ce <filestat>
}
801058d1:	c9                   	leave  
801058d2:	c3                   	ret    

801058d3 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801058d3:	55                   	push   %ebp
801058d4:	89 e5                	mov    %esp,%ebp
801058d6:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801058d9:	8d 45 d8             	lea    -0x28(%ebp),%eax
801058dc:	89 44 24 04          	mov    %eax,0x4(%esp)
801058e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801058e7:	e8 60 fc ff ff       	call   8010554c <argstr>
801058ec:	85 c0                	test   %eax,%eax
801058ee:	78 17                	js     80105907 <sys_link+0x34>
801058f0:	8d 45 dc             	lea    -0x24(%ebp),%eax
801058f3:	89 44 24 04          	mov    %eax,0x4(%esp)
801058f7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801058fe:	e8 49 fc ff ff       	call   8010554c <argstr>
80105903:	85 c0                	test   %eax,%eax
80105905:	79 0a                	jns    80105911 <sys_link+0x3e>
    return -1;
80105907:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010590c:	e9 3d 01 00 00       	jmp    80105a4e <sys_link+0x17b>

  begin_op();
80105911:	e8 ad db ff ff       	call   801034c3 <begin_op>
  if((ip = namei(old)) == 0){
80105916:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105919:	89 04 24             	mov    %eax,(%esp)
8010591c:	e8 10 cb ff ff       	call   80102431 <namei>
80105921:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105924:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105928:	75 0f                	jne    80105939 <sys_link+0x66>
    end_op();
8010592a:	e8 16 dc ff ff       	call   80103545 <end_op>
    return -1;
8010592f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105934:	e9 15 01 00 00       	jmp    80105a4e <sys_link+0x17b>
  }

  ilock(ip);
80105939:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010593c:	89 04 24             	mov    %eax,(%esp)
8010593f:	e8 da bf ff ff       	call   8010191e <ilock>
  if(ip->type == T_DIR){
80105944:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105947:	8b 40 50             	mov    0x50(%eax),%eax
8010594a:	66 83 f8 01          	cmp    $0x1,%ax
8010594e:	75 1a                	jne    8010596a <sys_link+0x97>
    iunlockput(ip);
80105950:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105953:	89 04 24             	mov    %eax,(%esp)
80105956:	e8 af c1 ff ff       	call   80101b0a <iunlockput>
    end_op();
8010595b:	e8 e5 db ff ff       	call   80103545 <end_op>
    return -1;
80105960:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105965:	e9 e4 00 00 00       	jmp    80105a4e <sys_link+0x17b>
  }

  ip->nlink++;
8010596a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010596d:	66 8b 40 56          	mov    0x56(%eax),%ax
80105971:	40                   	inc    %eax
80105972:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105975:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80105979:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010597c:	89 04 24             	mov    %eax,(%esp)
8010597f:	e8 d7 bd ff ff       	call   8010175b <iupdate>
  iunlock(ip);
80105984:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105987:	89 04 24             	mov    %eax,(%esp)
8010598a:	e8 a3 c0 ff ff       	call   80101a32 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
8010598f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105992:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105995:	89 54 24 04          	mov    %edx,0x4(%esp)
80105999:	89 04 24             	mov    %eax,(%esp)
8010599c:	e8 b2 ca ff ff       	call   80102453 <nameiparent>
801059a1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801059a4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801059a8:	75 02                	jne    801059ac <sys_link+0xd9>
    goto bad;
801059aa:	eb 68                	jmp    80105a14 <sys_link+0x141>
  ilock(dp);
801059ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059af:	89 04 24             	mov    %eax,(%esp)
801059b2:	e8 67 bf ff ff       	call   8010191e <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801059b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059ba:	8b 10                	mov    (%eax),%edx
801059bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059bf:	8b 00                	mov    (%eax),%eax
801059c1:	39 c2                	cmp    %eax,%edx
801059c3:	75 20                	jne    801059e5 <sys_link+0x112>
801059c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059c8:	8b 40 04             	mov    0x4(%eax),%eax
801059cb:	89 44 24 08          	mov    %eax,0x8(%esp)
801059cf:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801059d2:	89 44 24 04          	mov    %eax,0x4(%esp)
801059d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059d9:	89 04 24             	mov    %eax,(%esp)
801059dc:	e8 9c c7 ff ff       	call   8010217d <dirlink>
801059e1:	85 c0                	test   %eax,%eax
801059e3:	79 0d                	jns    801059f2 <sys_link+0x11f>
    iunlockput(dp);
801059e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059e8:	89 04 24             	mov    %eax,(%esp)
801059eb:	e8 1a c1 ff ff       	call   80101b0a <iunlockput>
    goto bad;
801059f0:	eb 22                	jmp    80105a14 <sys_link+0x141>
  }
  iunlockput(dp);
801059f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059f5:	89 04 24             	mov    %eax,(%esp)
801059f8:	e8 0d c1 ff ff       	call   80101b0a <iunlockput>
  iput(ip);
801059fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a00:	89 04 24             	mov    %eax,(%esp)
80105a03:	e8 6e c0 ff ff       	call   80101a76 <iput>

  end_op();
80105a08:	e8 38 db ff ff       	call   80103545 <end_op>

  return 0;
80105a0d:	b8 00 00 00 00       	mov    $0x0,%eax
80105a12:	eb 3a                	jmp    80105a4e <sys_link+0x17b>

bad:
  ilock(ip);
80105a14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a17:	89 04 24             	mov    %eax,(%esp)
80105a1a:	e8 ff be ff ff       	call   8010191e <ilock>
  ip->nlink--;
80105a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a22:	66 8b 40 56          	mov    0x56(%eax),%ax
80105a26:	48                   	dec    %eax
80105a27:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a2a:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80105a2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a31:	89 04 24             	mov    %eax,(%esp)
80105a34:	e8 22 bd ff ff       	call   8010175b <iupdate>
  iunlockput(ip);
80105a39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a3c:	89 04 24             	mov    %eax,(%esp)
80105a3f:	e8 c6 c0 ff ff       	call   80101b0a <iunlockput>
  end_op();
80105a44:	e8 fc da ff ff       	call   80103545 <end_op>
  return -1;
80105a49:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105a4e:	c9                   	leave  
80105a4f:	c3                   	ret    

80105a50 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105a50:	55                   	push   %ebp
80105a51:	89 e5                	mov    %esp,%ebp
80105a53:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105a56:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105a5d:	eb 4a                	jmp    80105aa9 <isdirempty+0x59>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105a5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a62:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105a69:	00 
80105a6a:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a6e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105a71:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a75:	8b 45 08             	mov    0x8(%ebp),%eax
80105a78:	89 04 24             	mov    %eax,(%esp)
80105a7b:	e8 22 c3 ff ff       	call   80101da2 <readi>
80105a80:	83 f8 10             	cmp    $0x10,%eax
80105a83:	74 0c                	je     80105a91 <isdirempty+0x41>
      panic("isdirempty: readi");
80105a85:	c7 04 24 9e 89 10 80 	movl   $0x8010899e,(%esp)
80105a8c:	e8 c3 aa ff ff       	call   80100554 <panic>
    if(de.inum != 0)
80105a91:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105a94:	66 85 c0             	test   %ax,%ax
80105a97:	74 07                	je     80105aa0 <isdirempty+0x50>
      return 0;
80105a99:	b8 00 00 00 00       	mov    $0x0,%eax
80105a9e:	eb 1b                	jmp    80105abb <isdirempty+0x6b>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aa3:	83 c0 10             	add    $0x10,%eax
80105aa6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105aa9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105aac:	8b 45 08             	mov    0x8(%ebp),%eax
80105aaf:	8b 40 58             	mov    0x58(%eax),%eax
80105ab2:	39 c2                	cmp    %eax,%edx
80105ab4:	72 a9                	jb     80105a5f <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105ab6:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105abb:	c9                   	leave  
80105abc:	c3                   	ret    

80105abd <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105abd:	55                   	push   %ebp
80105abe:	89 e5                	mov    %esp,%ebp
80105ac0:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105ac3:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105ac6:	89 44 24 04          	mov    %eax,0x4(%esp)
80105aca:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105ad1:	e8 76 fa ff ff       	call   8010554c <argstr>
80105ad6:	85 c0                	test   %eax,%eax
80105ad8:	79 0a                	jns    80105ae4 <sys_unlink+0x27>
    return -1;
80105ada:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105adf:	e9 a9 01 00 00       	jmp    80105c8d <sys_unlink+0x1d0>

  begin_op();
80105ae4:	e8 da d9 ff ff       	call   801034c3 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105ae9:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105aec:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105aef:	89 54 24 04          	mov    %edx,0x4(%esp)
80105af3:	89 04 24             	mov    %eax,(%esp)
80105af6:	e8 58 c9 ff ff       	call   80102453 <nameiparent>
80105afb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105afe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b02:	75 0f                	jne    80105b13 <sys_unlink+0x56>
    end_op();
80105b04:	e8 3c da ff ff       	call   80103545 <end_op>
    return -1;
80105b09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b0e:	e9 7a 01 00 00       	jmp    80105c8d <sys_unlink+0x1d0>
  }

  ilock(dp);
80105b13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b16:	89 04 24             	mov    %eax,(%esp)
80105b19:	e8 00 be ff ff       	call   8010191e <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105b1e:	c7 44 24 04 b0 89 10 	movl   $0x801089b0,0x4(%esp)
80105b25:	80 
80105b26:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105b29:	89 04 24             	mov    %eax,(%esp)
80105b2c:	e8 64 c5 ff ff       	call   80102095 <namecmp>
80105b31:	85 c0                	test   %eax,%eax
80105b33:	0f 84 3f 01 00 00    	je     80105c78 <sys_unlink+0x1bb>
80105b39:	c7 44 24 04 b2 89 10 	movl   $0x801089b2,0x4(%esp)
80105b40:	80 
80105b41:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105b44:	89 04 24             	mov    %eax,(%esp)
80105b47:	e8 49 c5 ff ff       	call   80102095 <namecmp>
80105b4c:	85 c0                	test   %eax,%eax
80105b4e:	0f 84 24 01 00 00    	je     80105c78 <sys_unlink+0x1bb>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105b54:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105b57:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b5b:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105b5e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b65:	89 04 24             	mov    %eax,(%esp)
80105b68:	e8 4a c5 ff ff       	call   801020b7 <dirlookup>
80105b6d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b70:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b74:	75 05                	jne    80105b7b <sys_unlink+0xbe>
    goto bad;
80105b76:	e9 fd 00 00 00       	jmp    80105c78 <sys_unlink+0x1bb>
  ilock(ip);
80105b7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b7e:	89 04 24             	mov    %eax,(%esp)
80105b81:	e8 98 bd ff ff       	call   8010191e <ilock>

  if(ip->nlink < 1)
80105b86:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b89:	66 8b 40 56          	mov    0x56(%eax),%ax
80105b8d:	66 85 c0             	test   %ax,%ax
80105b90:	7f 0c                	jg     80105b9e <sys_unlink+0xe1>
    panic("unlink: nlink < 1");
80105b92:	c7 04 24 b5 89 10 80 	movl   $0x801089b5,(%esp)
80105b99:	e8 b6 a9 ff ff       	call   80100554 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105b9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ba1:	8b 40 50             	mov    0x50(%eax),%eax
80105ba4:	66 83 f8 01          	cmp    $0x1,%ax
80105ba8:	75 1f                	jne    80105bc9 <sys_unlink+0x10c>
80105baa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bad:	89 04 24             	mov    %eax,(%esp)
80105bb0:	e8 9b fe ff ff       	call   80105a50 <isdirempty>
80105bb5:	85 c0                	test   %eax,%eax
80105bb7:	75 10                	jne    80105bc9 <sys_unlink+0x10c>
    iunlockput(ip);
80105bb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bbc:	89 04 24             	mov    %eax,(%esp)
80105bbf:	e8 46 bf ff ff       	call   80101b0a <iunlockput>
    goto bad;
80105bc4:	e9 af 00 00 00       	jmp    80105c78 <sys_unlink+0x1bb>
  }

  memset(&de, 0, sizeof(de));
80105bc9:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105bd0:	00 
80105bd1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105bd8:	00 
80105bd9:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105bdc:	89 04 24             	mov    %eax,(%esp)
80105bdf:	e8 a6 f5 ff ff       	call   8010518a <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105be4:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105be7:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105bee:	00 
80105bef:	89 44 24 08          	mov    %eax,0x8(%esp)
80105bf3:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105bf6:	89 44 24 04          	mov    %eax,0x4(%esp)
80105bfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bfd:	89 04 24             	mov    %eax,(%esp)
80105c00:	e8 01 c3 ff ff       	call   80101f06 <writei>
80105c05:	83 f8 10             	cmp    $0x10,%eax
80105c08:	74 0c                	je     80105c16 <sys_unlink+0x159>
    panic("unlink: writei");
80105c0a:	c7 04 24 c7 89 10 80 	movl   $0x801089c7,(%esp)
80105c11:	e8 3e a9 ff ff       	call   80100554 <panic>
  if(ip->type == T_DIR){
80105c16:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c19:	8b 40 50             	mov    0x50(%eax),%eax
80105c1c:	66 83 f8 01          	cmp    $0x1,%ax
80105c20:	75 1a                	jne    80105c3c <sys_unlink+0x17f>
    dp->nlink--;
80105c22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c25:	66 8b 40 56          	mov    0x56(%eax),%ax
80105c29:	48                   	dec    %eax
80105c2a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c2d:	66 89 42 56          	mov    %ax,0x56(%edx)
    iupdate(dp);
80105c31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c34:	89 04 24             	mov    %eax,(%esp)
80105c37:	e8 1f bb ff ff       	call   8010175b <iupdate>
  }
  iunlockput(dp);
80105c3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c3f:	89 04 24             	mov    %eax,(%esp)
80105c42:	e8 c3 be ff ff       	call   80101b0a <iunlockput>

  ip->nlink--;
80105c47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c4a:	66 8b 40 56          	mov    0x56(%eax),%ax
80105c4e:	48                   	dec    %eax
80105c4f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105c52:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80105c56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c59:	89 04 24             	mov    %eax,(%esp)
80105c5c:	e8 fa ba ff ff       	call   8010175b <iupdate>
  iunlockput(ip);
80105c61:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c64:	89 04 24             	mov    %eax,(%esp)
80105c67:	e8 9e be ff ff       	call   80101b0a <iunlockput>

  end_op();
80105c6c:	e8 d4 d8 ff ff       	call   80103545 <end_op>

  return 0;
80105c71:	b8 00 00 00 00       	mov    $0x0,%eax
80105c76:	eb 15                	jmp    80105c8d <sys_unlink+0x1d0>

bad:
  iunlockput(dp);
80105c78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c7b:	89 04 24             	mov    %eax,(%esp)
80105c7e:	e8 87 be ff ff       	call   80101b0a <iunlockput>
  end_op();
80105c83:	e8 bd d8 ff ff       	call   80103545 <end_op>
  return -1;
80105c88:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105c8d:	c9                   	leave  
80105c8e:	c3                   	ret    

80105c8f <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105c8f:	55                   	push   %ebp
80105c90:	89 e5                	mov    %esp,%ebp
80105c92:	83 ec 48             	sub    $0x48,%esp
80105c95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105c98:	8b 55 10             	mov    0x10(%ebp),%edx
80105c9b:	8b 45 14             	mov    0x14(%ebp),%eax
80105c9e:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105ca2:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105ca6:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105caa:	8d 45 de             	lea    -0x22(%ebp),%eax
80105cad:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cb1:	8b 45 08             	mov    0x8(%ebp),%eax
80105cb4:	89 04 24             	mov    %eax,(%esp)
80105cb7:	e8 97 c7 ff ff       	call   80102453 <nameiparent>
80105cbc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105cbf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105cc3:	75 0a                	jne    80105ccf <create+0x40>
    return 0;
80105cc5:	b8 00 00 00 00       	mov    $0x0,%eax
80105cca:	e9 79 01 00 00       	jmp    80105e48 <create+0x1b9>
  ilock(dp);
80105ccf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cd2:	89 04 24             	mov    %eax,(%esp)
80105cd5:	e8 44 bc ff ff       	call   8010191e <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80105cda:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105cdd:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ce1:	8d 45 de             	lea    -0x22(%ebp),%eax
80105ce4:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ce8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ceb:	89 04 24             	mov    %eax,(%esp)
80105cee:	e8 c4 c3 ff ff       	call   801020b7 <dirlookup>
80105cf3:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105cf6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105cfa:	74 46                	je     80105d42 <create+0xb3>
    iunlockput(dp);
80105cfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cff:	89 04 24             	mov    %eax,(%esp)
80105d02:	e8 03 be ff ff       	call   80101b0a <iunlockput>
    ilock(ip);
80105d07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d0a:	89 04 24             	mov    %eax,(%esp)
80105d0d:	e8 0c bc ff ff       	call   8010191e <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80105d12:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105d17:	75 14                	jne    80105d2d <create+0x9e>
80105d19:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d1c:	8b 40 50             	mov    0x50(%eax),%eax
80105d1f:	66 83 f8 02          	cmp    $0x2,%ax
80105d23:	75 08                	jne    80105d2d <create+0x9e>
      return ip;
80105d25:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d28:	e9 1b 01 00 00       	jmp    80105e48 <create+0x1b9>
    iunlockput(ip);
80105d2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d30:	89 04 24             	mov    %eax,(%esp)
80105d33:	e8 d2 bd ff ff       	call   80101b0a <iunlockput>
    return 0;
80105d38:	b8 00 00 00 00       	mov    $0x0,%eax
80105d3d:	e9 06 01 00 00       	jmp    80105e48 <create+0x1b9>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105d42:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105d46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d49:	8b 00                	mov    (%eax),%eax
80105d4b:	89 54 24 04          	mov    %edx,0x4(%esp)
80105d4f:	89 04 24             	mov    %eax,(%esp)
80105d52:	e8 32 b9 ff ff       	call   80101689 <ialloc>
80105d57:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d5a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d5e:	75 0c                	jne    80105d6c <create+0xdd>
    panic("create: ialloc");
80105d60:	c7 04 24 d6 89 10 80 	movl   $0x801089d6,(%esp)
80105d67:	e8 e8 a7 ff ff       	call   80100554 <panic>

  ilock(ip);
80105d6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d6f:	89 04 24             	mov    %eax,(%esp)
80105d72:	e8 a7 bb ff ff       	call   8010191e <ilock>
  ip->major = major;
80105d77:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105d7a:	8b 45 d0             	mov    -0x30(%ebp),%eax
80105d7d:	66 89 42 52          	mov    %ax,0x52(%edx)
  ip->minor = minor;
80105d81:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105d84:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105d87:	66 89 42 54          	mov    %ax,0x54(%edx)
  ip->nlink = 1;
80105d8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d8e:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105d94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d97:	89 04 24             	mov    %eax,(%esp)
80105d9a:	e8 bc b9 ff ff       	call   8010175b <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80105d9f:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105da4:	75 68                	jne    80105e0e <create+0x17f>
    dp->nlink++;  // for ".."
80105da6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105da9:	66 8b 40 56          	mov    0x56(%eax),%ax
80105dad:	40                   	inc    %eax
80105dae:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105db1:	66 89 42 56          	mov    %ax,0x56(%edx)
    iupdate(dp);
80105db5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105db8:	89 04 24             	mov    %eax,(%esp)
80105dbb:	e8 9b b9 ff ff       	call   8010175b <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105dc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dc3:	8b 40 04             	mov    0x4(%eax),%eax
80105dc6:	89 44 24 08          	mov    %eax,0x8(%esp)
80105dca:	c7 44 24 04 b0 89 10 	movl   $0x801089b0,0x4(%esp)
80105dd1:	80 
80105dd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dd5:	89 04 24             	mov    %eax,(%esp)
80105dd8:	e8 a0 c3 ff ff       	call   8010217d <dirlink>
80105ddd:	85 c0                	test   %eax,%eax
80105ddf:	78 21                	js     80105e02 <create+0x173>
80105de1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105de4:	8b 40 04             	mov    0x4(%eax),%eax
80105de7:	89 44 24 08          	mov    %eax,0x8(%esp)
80105deb:	c7 44 24 04 b2 89 10 	movl   $0x801089b2,0x4(%esp)
80105df2:	80 
80105df3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105df6:	89 04 24             	mov    %eax,(%esp)
80105df9:	e8 7f c3 ff ff       	call   8010217d <dirlink>
80105dfe:	85 c0                	test   %eax,%eax
80105e00:	79 0c                	jns    80105e0e <create+0x17f>
      panic("create dots");
80105e02:	c7 04 24 e5 89 10 80 	movl   $0x801089e5,(%esp)
80105e09:	e8 46 a7 ff ff       	call   80100554 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105e0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e11:	8b 40 04             	mov    0x4(%eax),%eax
80105e14:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e18:	8d 45 de             	lea    -0x22(%ebp),%eax
80105e1b:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e22:	89 04 24             	mov    %eax,(%esp)
80105e25:	e8 53 c3 ff ff       	call   8010217d <dirlink>
80105e2a:	85 c0                	test   %eax,%eax
80105e2c:	79 0c                	jns    80105e3a <create+0x1ab>
    panic("create: dirlink");
80105e2e:	c7 04 24 f1 89 10 80 	movl   $0x801089f1,(%esp)
80105e35:	e8 1a a7 ff ff       	call   80100554 <panic>

  iunlockput(dp);
80105e3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e3d:	89 04 24             	mov    %eax,(%esp)
80105e40:	e8 c5 bc ff ff       	call   80101b0a <iunlockput>

  return ip;
80105e45:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105e48:	c9                   	leave  
80105e49:	c3                   	ret    

80105e4a <sys_open>:

int
sys_open(void)
{
80105e4a:	55                   	push   %ebp
80105e4b:	89 e5                	mov    %esp,%ebp
80105e4d:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105e50:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105e53:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e57:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105e5e:	e8 e9 f6 ff ff       	call   8010554c <argstr>
80105e63:	85 c0                	test   %eax,%eax
80105e65:	78 17                	js     80105e7e <sys_open+0x34>
80105e67:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105e6a:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e6e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105e75:	e8 3c f6 ff ff       	call   801054b6 <argint>
80105e7a:	85 c0                	test   %eax,%eax
80105e7c:	79 0a                	jns    80105e88 <sys_open+0x3e>
    return -1;
80105e7e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e83:	e9 5b 01 00 00       	jmp    80105fe3 <sys_open+0x199>

  begin_op();
80105e88:	e8 36 d6 ff ff       	call   801034c3 <begin_op>

  if(omode & O_CREATE){
80105e8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105e90:	25 00 02 00 00       	and    $0x200,%eax
80105e95:	85 c0                	test   %eax,%eax
80105e97:	74 3b                	je     80105ed4 <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
80105e99:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105e9c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105ea3:	00 
80105ea4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105eab:	00 
80105eac:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80105eb3:	00 
80105eb4:	89 04 24             	mov    %eax,(%esp)
80105eb7:	e8 d3 fd ff ff       	call   80105c8f <create>
80105ebc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105ebf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ec3:	75 6a                	jne    80105f2f <sys_open+0xe5>
      end_op();
80105ec5:	e8 7b d6 ff ff       	call   80103545 <end_op>
      return -1;
80105eca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ecf:	e9 0f 01 00 00       	jmp    80105fe3 <sys_open+0x199>
    }
  } else {
    if((ip = namei(path)) == 0){
80105ed4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105ed7:	89 04 24             	mov    %eax,(%esp)
80105eda:	e8 52 c5 ff ff       	call   80102431 <namei>
80105edf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ee2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ee6:	75 0f                	jne    80105ef7 <sys_open+0xad>
      end_op();
80105ee8:	e8 58 d6 ff ff       	call   80103545 <end_op>
      return -1;
80105eed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ef2:	e9 ec 00 00 00       	jmp    80105fe3 <sys_open+0x199>
    }
    ilock(ip);
80105ef7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105efa:	89 04 24             	mov    %eax,(%esp)
80105efd:	e8 1c ba ff ff       	call   8010191e <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80105f02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f05:	8b 40 50             	mov    0x50(%eax),%eax
80105f08:	66 83 f8 01          	cmp    $0x1,%ax
80105f0c:	75 21                	jne    80105f2f <sys_open+0xe5>
80105f0e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f11:	85 c0                	test   %eax,%eax
80105f13:	74 1a                	je     80105f2f <sys_open+0xe5>
      iunlockput(ip);
80105f15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f18:	89 04 24             	mov    %eax,(%esp)
80105f1b:	e8 ea bb ff ff       	call   80101b0a <iunlockput>
      end_op();
80105f20:	e8 20 d6 ff ff       	call   80103545 <end_op>
      return -1;
80105f25:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f2a:	e9 b4 00 00 00       	jmp    80105fe3 <sys_open+0x199>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105f2f:	e8 28 b0 ff ff       	call   80100f5c <filealloc>
80105f34:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f37:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f3b:	74 14                	je     80105f51 <sys_open+0x107>
80105f3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f40:	89 04 24             	mov    %eax,(%esp)
80105f43:	e8 41 f7 ff ff       	call   80105689 <fdalloc>
80105f48:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105f4b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105f4f:	79 28                	jns    80105f79 <sys_open+0x12f>
    if(f)
80105f51:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f55:	74 0b                	je     80105f62 <sys_open+0x118>
      fileclose(f);
80105f57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f5a:	89 04 24             	mov    %eax,(%esp)
80105f5d:	e8 a2 b0 ff ff       	call   80101004 <fileclose>
    iunlockput(ip);
80105f62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f65:	89 04 24             	mov    %eax,(%esp)
80105f68:	e8 9d bb ff ff       	call   80101b0a <iunlockput>
    end_op();
80105f6d:	e8 d3 d5 ff ff       	call   80103545 <end_op>
    return -1;
80105f72:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f77:	eb 6a                	jmp    80105fe3 <sys_open+0x199>
  }
  iunlock(ip);
80105f79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f7c:	89 04 24             	mov    %eax,(%esp)
80105f7f:	e8 ae ba ff ff       	call   80101a32 <iunlock>
  end_op();
80105f84:	e8 bc d5 ff ff       	call   80103545 <end_op>

  f->type = FD_INODE;
80105f89:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f8c:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105f92:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f95:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f98:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105f9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f9e:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105fa5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fa8:	83 e0 01             	and    $0x1,%eax
80105fab:	85 c0                	test   %eax,%eax
80105fad:	0f 94 c0             	sete   %al
80105fb0:	88 c2                	mov    %al,%dl
80105fb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fb5:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105fb8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fbb:	83 e0 01             	and    $0x1,%eax
80105fbe:	85 c0                	test   %eax,%eax
80105fc0:	75 0a                	jne    80105fcc <sys_open+0x182>
80105fc2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fc5:	83 e0 02             	and    $0x2,%eax
80105fc8:	85 c0                	test   %eax,%eax
80105fca:	74 07                	je     80105fd3 <sys_open+0x189>
80105fcc:	b8 01 00 00 00       	mov    $0x1,%eax
80105fd1:	eb 05                	jmp    80105fd8 <sys_open+0x18e>
80105fd3:	b8 00 00 00 00       	mov    $0x0,%eax
80105fd8:	88 c2                	mov    %al,%dl
80105fda:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fdd:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105fe0:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105fe3:	c9                   	leave  
80105fe4:	c3                   	ret    

80105fe5 <sys_mkdir>:

int
sys_mkdir(void)
{
80105fe5:	55                   	push   %ebp
80105fe6:	89 e5                	mov    %esp,%ebp
80105fe8:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105feb:	e8 d3 d4 ff ff       	call   801034c3 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105ff0:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ff3:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ff7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105ffe:	e8 49 f5 ff ff       	call   8010554c <argstr>
80106003:	85 c0                	test   %eax,%eax
80106005:	78 2c                	js     80106033 <sys_mkdir+0x4e>
80106007:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010600a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106011:	00 
80106012:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106019:	00 
8010601a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106021:	00 
80106022:	89 04 24             	mov    %eax,(%esp)
80106025:	e8 65 fc ff ff       	call   80105c8f <create>
8010602a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010602d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106031:	75 0c                	jne    8010603f <sys_mkdir+0x5a>
    end_op();
80106033:	e8 0d d5 ff ff       	call   80103545 <end_op>
    return -1;
80106038:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010603d:	eb 15                	jmp    80106054 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
8010603f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106042:	89 04 24             	mov    %eax,(%esp)
80106045:	e8 c0 ba ff ff       	call   80101b0a <iunlockput>
  end_op();
8010604a:	e8 f6 d4 ff ff       	call   80103545 <end_op>
  return 0;
8010604f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106054:	c9                   	leave  
80106055:	c3                   	ret    

80106056 <sys_mknod>:

int
sys_mknod(void)
{
80106056:	55                   	push   %ebp
80106057:	89 e5                	mov    %esp,%ebp
80106059:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
8010605c:	e8 62 d4 ff ff       	call   801034c3 <begin_op>
  if((argstr(0, &path)) < 0 ||
80106061:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106064:	89 44 24 04          	mov    %eax,0x4(%esp)
80106068:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010606f:	e8 d8 f4 ff ff       	call   8010554c <argstr>
80106074:	85 c0                	test   %eax,%eax
80106076:	78 5e                	js     801060d6 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
80106078:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010607b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010607f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106086:	e8 2b f4 ff ff       	call   801054b6 <argint>
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
8010608b:	85 c0                	test   %eax,%eax
8010608d:	78 47                	js     801060d6 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
8010608f:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106092:	89 44 24 04          	mov    %eax,0x4(%esp)
80106096:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010609d:	e8 14 f4 ff ff       	call   801054b6 <argint>
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
801060a2:	85 c0                	test   %eax,%eax
801060a4:	78 30                	js     801060d6 <sys_mknod+0x80>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
801060a6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801060a9:	0f bf c8             	movswl %ax,%ecx
801060ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
801060af:	0f bf d0             	movswl %ax,%edx
801060b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801060b5:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801060b9:	89 54 24 08          	mov    %edx,0x8(%esp)
801060bd:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
801060c4:	00 
801060c5:	89 04 24             	mov    %eax,(%esp)
801060c8:	e8 c2 fb ff ff       	call   80105c8f <create>
801060cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
801060d0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801060d4:	75 0c                	jne    801060e2 <sys_mknod+0x8c>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
801060d6:	e8 6a d4 ff ff       	call   80103545 <end_op>
    return -1;
801060db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060e0:	eb 15                	jmp    801060f7 <sys_mknod+0xa1>
  }
  iunlockput(ip);
801060e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060e5:	89 04 24             	mov    %eax,(%esp)
801060e8:	e8 1d ba ff ff       	call   80101b0a <iunlockput>
  end_op();
801060ed:	e8 53 d4 ff ff       	call   80103545 <end_op>
  return 0;
801060f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801060f7:	c9                   	leave  
801060f8:	c3                   	ret    

801060f9 <sys_chdir>:

int
sys_chdir(void)
{
801060f9:	55                   	push   %ebp
801060fa:	89 e5                	mov    %esp,%ebp
801060fc:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
801060ff:	e8 bf d3 ff ff       	call   801034c3 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106104:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106107:	89 44 24 04          	mov    %eax,0x4(%esp)
8010610b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106112:	e8 35 f4 ff ff       	call   8010554c <argstr>
80106117:	85 c0                	test   %eax,%eax
80106119:	78 14                	js     8010612f <sys_chdir+0x36>
8010611b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010611e:	89 04 24             	mov    %eax,(%esp)
80106121:	e8 0b c3 ff ff       	call   80102431 <namei>
80106126:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106129:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010612d:	75 0c                	jne    8010613b <sys_chdir+0x42>
    end_op();
8010612f:	e8 11 d4 ff ff       	call   80103545 <end_op>
    return -1;
80106134:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106139:	eb 60                	jmp    8010619b <sys_chdir+0xa2>
  }
  ilock(ip);
8010613b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010613e:	89 04 24             	mov    %eax,(%esp)
80106141:	e8 d8 b7 ff ff       	call   8010191e <ilock>
  if(ip->type != T_DIR){
80106146:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106149:	8b 40 50             	mov    0x50(%eax),%eax
8010614c:	66 83 f8 01          	cmp    $0x1,%ax
80106150:	74 17                	je     80106169 <sys_chdir+0x70>
    iunlockput(ip);
80106152:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106155:	89 04 24             	mov    %eax,(%esp)
80106158:	e8 ad b9 ff ff       	call   80101b0a <iunlockput>
    end_op();
8010615d:	e8 e3 d3 ff ff       	call   80103545 <end_op>
    return -1;
80106162:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106167:	eb 32                	jmp    8010619b <sys_chdir+0xa2>
  }
  iunlock(ip);
80106169:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010616c:	89 04 24             	mov    %eax,(%esp)
8010616f:	e8 be b8 ff ff       	call   80101a32 <iunlock>
  iput(proc->cwd);
80106174:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010617a:	8b 40 68             	mov    0x68(%eax),%eax
8010617d:	89 04 24             	mov    %eax,(%esp)
80106180:	e8 f1 b8 ff ff       	call   80101a76 <iput>
  end_op();
80106185:	e8 bb d3 ff ff       	call   80103545 <end_op>
  proc->cwd = ip;
8010618a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106190:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106193:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106196:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010619b:	c9                   	leave  
8010619c:	c3                   	ret    

8010619d <sys_exec>:

int
sys_exec(void)
{
8010619d:	55                   	push   %ebp
8010619e:	89 e5                	mov    %esp,%ebp
801061a0:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801061a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801061a9:	89 44 24 04          	mov    %eax,0x4(%esp)
801061ad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801061b4:	e8 93 f3 ff ff       	call   8010554c <argstr>
801061b9:	85 c0                	test   %eax,%eax
801061bb:	78 1a                	js     801061d7 <sys_exec+0x3a>
801061bd:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801061c3:	89 44 24 04          	mov    %eax,0x4(%esp)
801061c7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801061ce:	e8 e3 f2 ff ff       	call   801054b6 <argint>
801061d3:	85 c0                	test   %eax,%eax
801061d5:	79 0a                	jns    801061e1 <sys_exec+0x44>
    return -1;
801061d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061dc:	e9 c7 00 00 00       	jmp    801062a8 <sys_exec+0x10b>
  }
  memset(argv, 0, sizeof(argv));
801061e1:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801061e8:	00 
801061e9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801061f0:	00 
801061f1:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801061f7:	89 04 24             	mov    %eax,(%esp)
801061fa:	e8 8b ef ff ff       	call   8010518a <memset>
  for(i=0;; i++){
801061ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106206:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106209:	83 f8 1f             	cmp    $0x1f,%eax
8010620c:	76 0a                	jbe    80106218 <sys_exec+0x7b>
      return -1;
8010620e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106213:	e9 90 00 00 00       	jmp    801062a8 <sys_exec+0x10b>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106218:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010621b:	c1 e0 02             	shl    $0x2,%eax
8010621e:	89 c2                	mov    %eax,%edx
80106220:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106226:	01 c2                	add    %eax,%edx
80106228:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
8010622e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106232:	89 14 24             	mov    %edx,(%esp)
80106235:	e8 e2 f1 ff ff       	call   8010541c <fetchint>
8010623a:	85 c0                	test   %eax,%eax
8010623c:	79 07                	jns    80106245 <sys_exec+0xa8>
      return -1;
8010623e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106243:	eb 63                	jmp    801062a8 <sys_exec+0x10b>
    if(uarg == 0){
80106245:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010624b:	85 c0                	test   %eax,%eax
8010624d:	75 26                	jne    80106275 <sys_exec+0xd8>
      argv[i] = 0;
8010624f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106252:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106259:	00 00 00 00 
      break;
8010625d:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
8010625e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106261:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106267:	89 54 24 04          	mov    %edx,0x4(%esp)
8010626b:	89 04 24             	mov    %eax,(%esp)
8010626e:	e8 8d a8 ff ff       	call   80100b00 <exec>
80106273:	eb 33                	jmp    801062a8 <sys_exec+0x10b>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106275:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010627b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010627e:	c1 e2 02             	shl    $0x2,%edx
80106281:	01 c2                	add    %eax,%edx
80106283:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106289:	89 54 24 04          	mov    %edx,0x4(%esp)
8010628d:	89 04 24             	mov    %eax,(%esp)
80106290:	e8 c1 f1 ff ff       	call   80105456 <fetchstr>
80106295:	85 c0                	test   %eax,%eax
80106297:	79 07                	jns    801062a0 <sys_exec+0x103>
      return -1;
80106299:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010629e:	eb 08                	jmp    801062a8 <sys_exec+0x10b>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
801062a0:	ff 45 f4             	incl   -0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
801062a3:	e9 5e ff ff ff       	jmp    80106206 <sys_exec+0x69>
  return exec(path, argv);
}
801062a8:	c9                   	leave  
801062a9:	c3                   	ret    

801062aa <sys_pipe>:

int
sys_pipe(void)
{
801062aa:	55                   	push   %ebp
801062ab:	89 e5                	mov    %esp,%ebp
801062ad:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801062b0:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
801062b7:	00 
801062b8:	8d 45 ec             	lea    -0x14(%ebp),%eax
801062bb:	89 44 24 04          	mov    %eax,0x4(%esp)
801062bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801062c6:	e8 19 f2 ff ff       	call   801054e4 <argptr>
801062cb:	85 c0                	test   %eax,%eax
801062cd:	79 0a                	jns    801062d9 <sys_pipe+0x2f>
    return -1;
801062cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062d4:	e9 9b 00 00 00       	jmp    80106374 <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
801062d9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801062dc:	89 44 24 04          	mov    %eax,0x4(%esp)
801062e0:	8d 45 e8             	lea    -0x18(%ebp),%eax
801062e3:	89 04 24             	mov    %eax,(%esp)
801062e6:	e8 05 dc ff ff       	call   80103ef0 <pipealloc>
801062eb:	85 c0                	test   %eax,%eax
801062ed:	79 07                	jns    801062f6 <sys_pipe+0x4c>
    return -1;
801062ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062f4:	eb 7e                	jmp    80106374 <sys_pipe+0xca>
  fd0 = -1;
801062f6:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801062fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106300:	89 04 24             	mov    %eax,(%esp)
80106303:	e8 81 f3 ff ff       	call   80105689 <fdalloc>
80106308:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010630b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010630f:	78 14                	js     80106325 <sys_pipe+0x7b>
80106311:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106314:	89 04 24             	mov    %eax,(%esp)
80106317:	e8 6d f3 ff ff       	call   80105689 <fdalloc>
8010631c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010631f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106323:	79 37                	jns    8010635c <sys_pipe+0xb2>
    if(fd0 >= 0)
80106325:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106329:	78 14                	js     8010633f <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
8010632b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106331:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106334:	83 c2 08             	add    $0x8,%edx
80106337:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010633e:	00 
    fileclose(rf);
8010633f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106342:	89 04 24             	mov    %eax,(%esp)
80106345:	e8 ba ac ff ff       	call   80101004 <fileclose>
    fileclose(wf);
8010634a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010634d:	89 04 24             	mov    %eax,(%esp)
80106350:	e8 af ac ff ff       	call   80101004 <fileclose>
    return -1;
80106355:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010635a:	eb 18                	jmp    80106374 <sys_pipe+0xca>
  }
  fd[0] = fd0;
8010635c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010635f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106362:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106364:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106367:	8d 50 04             	lea    0x4(%eax),%edx
8010636a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010636d:	89 02                	mov    %eax,(%edx)
  return 0;
8010636f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106374:	c9                   	leave  
80106375:	c3                   	ret    

80106376 <sys_pipe_count>:

int
sys_pipe_count(void)
{
80106376:	55                   	push   %ebp
80106377:	89 e5                	mov    %esp,%ebp
80106379:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  if(argfd(0, 0, &f) < 0) {
8010637c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010637f:	89 44 24 08          	mov    %eax,0x8(%esp)
80106383:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010638a:	00 
8010638b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106392:	e8 7d f2 ff ff       	call   80105614 <argfd>
80106397:	85 c0                	test   %eax,%eax
80106399:	79 07                	jns    801063a2 <sys_pipe_count+0x2c>
    return -1;
8010639b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063a0:	eb 0e                	jmp    801063b0 <sys_pipe_count+0x3a>
  }
  
  return pipe_count(f->pipe);
801063a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063a5:	8b 40 0c             	mov    0xc(%eax),%eax
801063a8:	89 04 24             	mov    %eax,(%esp)
801063ab:	e8 f1 de ff ff       	call   801042a1 <pipe_count>
}
801063b0:	c9                   	leave  
801063b1:	c3                   	ret    
	...

801063b4 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801063b4:	55                   	push   %ebp
801063b5:	89 e5                	mov    %esp,%ebp
801063b7:	83 ec 08             	sub    $0x8,%esp
801063ba:	8b 45 08             	mov    0x8(%ebp),%eax
801063bd:	8b 55 0c             	mov    0xc(%ebp),%edx
801063c0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801063c4:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801063c7:	8a 45 f8             	mov    -0x8(%ebp),%al
801063ca:	8b 55 fc             	mov    -0x4(%ebp),%edx
801063cd:	ee                   	out    %al,(%dx)
}
801063ce:	c9                   	leave  
801063cf:	c3                   	ret    

801063d0 <outw>:

static inline void
outw(ushort port, ushort data)
{
801063d0:	55                   	push   %ebp
801063d1:	89 e5                	mov    %esp,%ebp
801063d3:	83 ec 08             	sub    $0x8,%esp
801063d6:	8b 55 08             	mov    0x8(%ebp),%edx
801063d9:	8b 45 0c             	mov    0xc(%ebp),%eax
801063dc:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801063e0:	66 89 45 f8          	mov    %ax,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801063e4:	8b 45 f8             	mov    -0x8(%ebp),%eax
801063e7:	8b 55 fc             	mov    -0x4(%ebp),%edx
801063ea:	66 ef                	out    %ax,(%dx)
}
801063ec:	c9                   	leave  
801063ed:	c3                   	ret    

801063ee <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
801063ee:	55                   	push   %ebp
801063ef:	89 e5                	mov    %esp,%ebp
801063f1:	83 ec 08             	sub    $0x8,%esp
  return fork();
801063f4:	e8 fb e1 ff ff       	call   801045f4 <fork>
}
801063f9:	c9                   	leave  
801063fa:	c3                   	ret    

801063fb <sys_exit>:

int
sys_exit(void)
{
801063fb:	55                   	push   %ebp
801063fc:	89 e5                	mov    %esp,%ebp
801063fe:	83 ec 08             	sub    $0x8,%esp
  exit();
80106401:	e8 68 e3 ff ff       	call   8010476e <exit>
  return 0;  // not reached
80106406:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010640b:	c9                   	leave  
8010640c:	c3                   	ret    

8010640d <sys_wait>:

int
sys_wait(void)
{
8010640d:	55                   	push   %ebp
8010640e:	89 e5                	mov    %esp,%ebp
80106410:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106413:	e8 77 e4 ff ff       	call   8010488f <wait>
}
80106418:	c9                   	leave  
80106419:	c3                   	ret    

8010641a <sys_kill>:

int
sys_kill(void)
{
8010641a:	55                   	push   %ebp
8010641b:	89 e5                	mov    %esp,%ebp
8010641d:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106420:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106423:	89 44 24 04          	mov    %eax,0x4(%esp)
80106427:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010642e:	e8 83 f0 ff ff       	call   801054b6 <argint>
80106433:	85 c0                	test   %eax,%eax
80106435:	79 07                	jns    8010643e <sys_kill+0x24>
    return -1;
80106437:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010643c:	eb 0b                	jmp    80106449 <sys_kill+0x2f>
  return kill(pid);
8010643e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106441:	89 04 24             	mov    %eax,(%esp)
80106444:	e8 11 e8 ff ff       	call   80104c5a <kill>
}
80106449:	c9                   	leave  
8010644a:	c3                   	ret    

8010644b <sys_getpid>:

int
sys_getpid(void)
{
8010644b:	55                   	push   %ebp
8010644c:	89 e5                	mov    %esp,%ebp
  return proc->pid;
8010644e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106454:	8b 40 10             	mov    0x10(%eax),%eax
}
80106457:	5d                   	pop    %ebp
80106458:	c3                   	ret    

80106459 <sys_sbrk>:

int
sys_sbrk(void)
{
80106459:	55                   	push   %ebp
8010645a:	89 e5                	mov    %esp,%ebp
8010645c:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010645f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106462:	89 44 24 04          	mov    %eax,0x4(%esp)
80106466:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010646d:	e8 44 f0 ff ff       	call   801054b6 <argint>
80106472:	85 c0                	test   %eax,%eax
80106474:	79 07                	jns    8010647d <sys_sbrk+0x24>
    return -1;
80106476:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010647b:	eb 24                	jmp    801064a1 <sys_sbrk+0x48>
  addr = proc->sz;
8010647d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106483:	8b 00                	mov    (%eax),%eax
80106485:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106488:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010648b:	89 04 24             	mov    %eax,(%esp)
8010648e:	e8 bc e0 ff ff       	call   8010454f <growproc>
80106493:	85 c0                	test   %eax,%eax
80106495:	79 07                	jns    8010649e <sys_sbrk+0x45>
    return -1;
80106497:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010649c:	eb 03                	jmp    801064a1 <sys_sbrk+0x48>
  return addr;
8010649e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801064a1:	c9                   	leave  
801064a2:	c3                   	ret    

801064a3 <sys_sleep>:

int
sys_sleep(void)
{
801064a3:	55                   	push   %ebp
801064a4:	89 e5                	mov    %esp,%ebp
801064a6:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
801064a9:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064ac:	89 44 24 04          	mov    %eax,0x4(%esp)
801064b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801064b7:	e8 fa ef ff ff       	call   801054b6 <argint>
801064bc:	85 c0                	test   %eax,%eax
801064be:	79 07                	jns    801064c7 <sys_sleep+0x24>
    return -1;
801064c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064c5:	eb 6c                	jmp    80106533 <sys_sleep+0x90>
  acquire(&tickslock);
801064c7:	c7 04 24 80 5d 11 80 	movl   $0x80115d80,(%esp)
801064ce:	e8 54 ea ff ff       	call   80104f27 <acquire>
  ticks0 = ticks;
801064d3:	a1 c0 65 11 80       	mov    0x801165c0,%eax
801064d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801064db:	eb 34                	jmp    80106511 <sys_sleep+0x6e>
    if(proc->killed){
801064dd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801064e3:	8b 40 24             	mov    0x24(%eax),%eax
801064e6:	85 c0                	test   %eax,%eax
801064e8:	74 13                	je     801064fd <sys_sleep+0x5a>
      release(&tickslock);
801064ea:	c7 04 24 80 5d 11 80 	movl   $0x80115d80,(%esp)
801064f1:	e8 98 ea ff ff       	call   80104f8e <release>
      return -1;
801064f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064fb:	eb 36                	jmp    80106533 <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
801064fd:	c7 44 24 04 80 5d 11 	movl   $0x80115d80,0x4(%esp)
80106504:	80 
80106505:	c7 04 24 c0 65 11 80 	movl   $0x801165c0,(%esp)
8010650c:	e8 45 e6 ff ff       	call   80104b56 <sleep>

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106511:	a1 c0 65 11 80       	mov    0x801165c0,%eax
80106516:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106519:	89 c2                	mov    %eax,%edx
8010651b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010651e:	39 c2                	cmp    %eax,%edx
80106520:	72 bb                	jb     801064dd <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106522:	c7 04 24 80 5d 11 80 	movl   $0x80115d80,(%esp)
80106529:	e8 60 ea ff ff       	call   80104f8e <release>
  return 0;
8010652e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106533:	c9                   	leave  
80106534:	c3                   	ret    

80106535 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106535:	55                   	push   %ebp
80106536:	89 e5                	mov    %esp,%ebp
80106538:	83 ec 28             	sub    $0x28,%esp
  uint xticks;

  acquire(&tickslock);
8010653b:	c7 04 24 80 5d 11 80 	movl   $0x80115d80,(%esp)
80106542:	e8 e0 e9 ff ff       	call   80104f27 <acquire>
  xticks = ticks;
80106547:	a1 c0 65 11 80       	mov    0x801165c0,%eax
8010654c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
8010654f:	c7 04 24 80 5d 11 80 	movl   $0x80115d80,(%esp)
80106556:	e8 33 ea ff ff       	call   80104f8e <release>
  return xticks;
8010655b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010655e:	c9                   	leave  
8010655f:	c3                   	ret    

80106560 <sys_mygetpid>:

int
sys_mygetpid(void)
{
80106560:	55                   	push   %ebp
80106561:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80106563:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106569:	8b 40 10             	mov    0x10(%eax),%eax
}
8010656c:	5d                   	pop    %ebp
8010656d:	c3                   	ret    

8010656e <sys_halt>:

int
sys_halt(void)
{
8010656e:	55                   	push   %ebp
8010656f:	89 e5                	mov    %esp,%ebp
80106571:	57                   	push   %edi
80106572:	56                   	push   %esi
80106573:	53                   	push   %ebx
80106574:	83 ec 18             	sub    $0x18,%esp
  const char s[] = "Shutdown";
80106577:	8d 55 e7             	lea    -0x19(%ebp),%edx
8010657a:	bb 01 8a 10 80       	mov    $0x80108a01,%ebx
8010657f:	b8 09 00 00 00       	mov    $0x9,%eax
80106584:	89 d7                	mov    %edx,%edi
80106586:	89 de                	mov    %ebx,%esi
80106588:	89 c1                	mov    %eax,%ecx
8010658a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  const char *p;

  outw( 0xB004, 0x0 | 0x2000 );
8010658c:	c7 44 24 04 00 20 00 	movl   $0x2000,0x4(%esp)
80106593:	00 
80106594:	c7 04 24 04 b0 00 00 	movl   $0xb004,(%esp)
8010659b:	e8 30 fe ff ff       	call   801063d0 <outw>

  for (p = s; *p != '\0'; p++)
801065a0:	8d 45 e7             	lea    -0x19(%ebp),%eax
801065a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
801065a6:	eb 1b                	jmp    801065c3 <sys_halt+0x55>
    outb (0x8900, *p);
801065a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065ab:	8a 00                	mov    (%eax),%al
801065ad:	0f b6 c0             	movzbl %al,%eax
801065b0:	89 44 24 04          	mov    %eax,0x4(%esp)
801065b4:	c7 04 24 00 89 00 00 	movl   $0x8900,(%esp)
801065bb:	e8 f4 fd ff ff       	call   801063b4 <outb>
  const char s[] = "Shutdown";
  const char *p;

  outw( 0xB004, 0x0 | 0x2000 );

  for (p = s; *p != '\0'; p++)
801065c0:	ff 45 f0             	incl   -0x10(%ebp)
801065c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065c6:	8a 00                	mov    (%eax),%al
801065c8:	84 c0                	test   %al,%al
801065ca:	75 dc                	jne    801065a8 <sys_halt+0x3a>
    outb (0x8900, *p);

  return 0;
801065cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
801065d1:	83 c4 18             	add    $0x18,%esp
801065d4:	5b                   	pop    %ebx
801065d5:	5e                   	pop    %esi
801065d6:	5f                   	pop    %edi
801065d7:	5d                   	pop    %ebp
801065d8:	c3                   	ret    
801065d9:	00 00                	add    %al,(%eax)
	...

801065dc <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801065dc:	55                   	push   %ebp
801065dd:	89 e5                	mov    %esp,%ebp
801065df:	83 ec 08             	sub    $0x8,%esp
801065e2:	8b 45 08             	mov    0x8(%ebp),%eax
801065e5:	8b 55 0c             	mov    0xc(%ebp),%edx
801065e8:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801065ec:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801065ef:	8a 45 f8             	mov    -0x8(%ebp),%al
801065f2:	8b 55 fc             	mov    -0x4(%ebp),%edx
801065f5:	ee                   	out    %al,(%dx)
}
801065f6:	c9                   	leave  
801065f7:	c3                   	ret    

801065f8 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
801065f8:	55                   	push   %ebp
801065f9:	89 e5                	mov    %esp,%ebp
801065fb:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
801065fe:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
80106605:	00 
80106606:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
8010660d:	e8 ca ff ff ff       	call   801065dc <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
80106612:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
80106619:	00 
8010661a:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106621:	e8 b6 ff ff ff       	call   801065dc <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80106626:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
8010662d:	00 
8010662e:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106635:	e8 a2 ff ff ff       	call   801065dc <outb>
  picenable(IRQ_TIMER);
8010663a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106641:	e8 3e d7 ff ff       	call   80103d84 <picenable>
}
80106646:	c9                   	leave  
80106647:	c3                   	ret    

80106648 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106648:	1e                   	push   %ds
  pushl %es
80106649:	06                   	push   %es
  pushl %fs
8010664a:	0f a0                	push   %fs
  pushl %gs
8010664c:	0f a8                	push   %gs
  pushal
8010664e:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
8010664f:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106653:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106655:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80106657:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
8010665b:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
8010665d:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
8010665f:	54                   	push   %esp
  call trap
80106660:	e8 c0 01 00 00       	call   80106825 <trap>
  addl $4, %esp
80106665:	83 c4 04             	add    $0x4,%esp

80106668 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106668:	61                   	popa   
  popl %gs
80106669:	0f a9                	pop    %gs
  popl %fs
8010666b:	0f a1                	pop    %fs
  popl %es
8010666d:	07                   	pop    %es
  popl %ds
8010666e:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
8010666f:	83 c4 08             	add    $0x8,%esp
  iret
80106672:	cf                   	iret   
	...

80106674 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106674:	55                   	push   %ebp
80106675:	89 e5                	mov    %esp,%ebp
80106677:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010667a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010667d:	48                   	dec    %eax
8010667e:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106682:	8b 45 08             	mov    0x8(%ebp),%eax
80106685:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106689:	8b 45 08             	mov    0x8(%ebp),%eax
8010668c:	c1 e8 10             	shr    $0x10,%eax
8010668f:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106693:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106696:	0f 01 18             	lidtl  (%eax)
}
80106699:	c9                   	leave  
8010669a:	c3                   	ret    

8010669b <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
8010669b:	55                   	push   %ebp
8010669c:	89 e5                	mov    %esp,%ebp
8010669e:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801066a1:	0f 20 d0             	mov    %cr2,%eax
801066a4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801066a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801066aa:	c9                   	leave  
801066ab:	c3                   	ret    

801066ac <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801066ac:	55                   	push   %ebp
801066ad:	89 e5                	mov    %esp,%ebp
801066af:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
801066b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801066b9:	e9 b8 00 00 00       	jmp    80106776 <tvinit+0xca>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801066be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066c1:	8b 04 85 a4 b0 10 80 	mov    -0x7fef4f5c(,%eax,4),%eax
801066c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801066cb:	66 89 04 d5 c0 5d 11 	mov    %ax,-0x7feea240(,%edx,8)
801066d2:	80 
801066d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066d6:	66 c7 04 c5 c2 5d 11 	movw   $0x8,-0x7feea23e(,%eax,8)
801066dd:	80 08 00 
801066e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066e3:	8a 14 c5 c4 5d 11 80 	mov    -0x7feea23c(,%eax,8),%dl
801066ea:	83 e2 e0             	and    $0xffffffe0,%edx
801066ed:	88 14 c5 c4 5d 11 80 	mov    %dl,-0x7feea23c(,%eax,8)
801066f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066f7:	8a 14 c5 c4 5d 11 80 	mov    -0x7feea23c(,%eax,8),%dl
801066fe:	83 e2 1f             	and    $0x1f,%edx
80106701:	88 14 c5 c4 5d 11 80 	mov    %dl,-0x7feea23c(,%eax,8)
80106708:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010670b:	8a 14 c5 c5 5d 11 80 	mov    -0x7feea23b(,%eax,8),%dl
80106712:	83 e2 f0             	and    $0xfffffff0,%edx
80106715:	83 ca 0e             	or     $0xe,%edx
80106718:	88 14 c5 c5 5d 11 80 	mov    %dl,-0x7feea23b(,%eax,8)
8010671f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106722:	8a 14 c5 c5 5d 11 80 	mov    -0x7feea23b(,%eax,8),%dl
80106729:	83 e2 ef             	and    $0xffffffef,%edx
8010672c:	88 14 c5 c5 5d 11 80 	mov    %dl,-0x7feea23b(,%eax,8)
80106733:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106736:	8a 14 c5 c5 5d 11 80 	mov    -0x7feea23b(,%eax,8),%dl
8010673d:	83 e2 9f             	and    $0xffffff9f,%edx
80106740:	88 14 c5 c5 5d 11 80 	mov    %dl,-0x7feea23b(,%eax,8)
80106747:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010674a:	8a 14 c5 c5 5d 11 80 	mov    -0x7feea23b(,%eax,8),%dl
80106751:	83 ca 80             	or     $0xffffff80,%edx
80106754:	88 14 c5 c5 5d 11 80 	mov    %dl,-0x7feea23b(,%eax,8)
8010675b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010675e:	8b 04 85 a4 b0 10 80 	mov    -0x7fef4f5c(,%eax,4),%eax
80106765:	c1 e8 10             	shr    $0x10,%eax
80106768:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010676b:	66 89 04 d5 c6 5d 11 	mov    %ax,-0x7feea23a(,%edx,8)
80106772:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106773:	ff 45 f4             	incl   -0xc(%ebp)
80106776:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010677d:	0f 8e 3b ff ff ff    	jle    801066be <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106783:	a1 a4 b1 10 80       	mov    0x8010b1a4,%eax
80106788:	66 a3 c0 5f 11 80    	mov    %ax,0x80115fc0
8010678e:	66 c7 05 c2 5f 11 80 	movw   $0x8,0x80115fc2
80106795:	08 00 
80106797:	a0 c4 5f 11 80       	mov    0x80115fc4,%al
8010679c:	83 e0 e0             	and    $0xffffffe0,%eax
8010679f:	a2 c4 5f 11 80       	mov    %al,0x80115fc4
801067a4:	a0 c4 5f 11 80       	mov    0x80115fc4,%al
801067a9:	83 e0 1f             	and    $0x1f,%eax
801067ac:	a2 c4 5f 11 80       	mov    %al,0x80115fc4
801067b1:	a0 c5 5f 11 80       	mov    0x80115fc5,%al
801067b6:	83 c8 0f             	or     $0xf,%eax
801067b9:	a2 c5 5f 11 80       	mov    %al,0x80115fc5
801067be:	a0 c5 5f 11 80       	mov    0x80115fc5,%al
801067c3:	83 e0 ef             	and    $0xffffffef,%eax
801067c6:	a2 c5 5f 11 80       	mov    %al,0x80115fc5
801067cb:	a0 c5 5f 11 80       	mov    0x80115fc5,%al
801067d0:	83 c8 60             	or     $0x60,%eax
801067d3:	a2 c5 5f 11 80       	mov    %al,0x80115fc5
801067d8:	a0 c5 5f 11 80       	mov    0x80115fc5,%al
801067dd:	83 c8 80             	or     $0xffffff80,%eax
801067e0:	a2 c5 5f 11 80       	mov    %al,0x80115fc5
801067e5:	a1 a4 b1 10 80       	mov    0x8010b1a4,%eax
801067ea:	c1 e8 10             	shr    $0x10,%eax
801067ed:	66 a3 c6 5f 11 80    	mov    %ax,0x80115fc6

  initlock(&tickslock, "time");
801067f3:	c7 44 24 04 0c 8a 10 	movl   $0x80108a0c,0x4(%esp)
801067fa:	80 
801067fb:	c7 04 24 80 5d 11 80 	movl   $0x80115d80,(%esp)
80106802:	e8 ff e6 ff ff       	call   80104f06 <initlock>
}
80106807:	c9                   	leave  
80106808:	c3                   	ret    

80106809 <idtinit>:

void
idtinit(void)
{
80106809:	55                   	push   %ebp
8010680a:	89 e5                	mov    %esp,%ebp
8010680c:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
8010680f:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
80106816:	00 
80106817:	c7 04 24 c0 5d 11 80 	movl   $0x80115dc0,(%esp)
8010681e:	e8 51 fe ff ff       	call   80106674 <lidt>
}
80106823:	c9                   	leave  
80106824:	c3                   	ret    

80106825 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106825:	55                   	push   %ebp
80106826:	89 e5                	mov    %esp,%ebp
80106828:	57                   	push   %edi
80106829:	56                   	push   %esi
8010682a:	53                   	push   %ebx
8010682b:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
8010682e:	8b 45 08             	mov    0x8(%ebp),%eax
80106831:	8b 40 30             	mov    0x30(%eax),%eax
80106834:	83 f8 40             	cmp    $0x40,%eax
80106837:	75 3f                	jne    80106878 <trap+0x53>
    if(proc->killed)
80106839:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010683f:	8b 40 24             	mov    0x24(%eax),%eax
80106842:	85 c0                	test   %eax,%eax
80106844:	74 05                	je     8010684b <trap+0x26>
      exit();
80106846:	e8 23 df ff ff       	call   8010476e <exit>
    proc->tf = tf;
8010684b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106851:	8b 55 08             	mov    0x8(%ebp),%edx
80106854:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106857:	e8 27 ed ff ff       	call   80105583 <syscall>
    if(proc->killed)
8010685c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106862:	8b 40 24             	mov    0x24(%eax),%eax
80106865:	85 c0                	test   %eax,%eax
80106867:	74 0a                	je     80106873 <trap+0x4e>
      exit();
80106869:	e8 00 df ff ff       	call   8010476e <exit>
    return;
8010686e:	e9 11 02 00 00       	jmp    80106a84 <trap+0x25f>
80106873:	e9 0c 02 00 00       	jmp    80106a84 <trap+0x25f>
  }

  switch(tf->trapno){
80106878:	8b 45 08             	mov    0x8(%ebp),%eax
8010687b:	8b 40 30             	mov    0x30(%eax),%eax
8010687e:	83 e8 20             	sub    $0x20,%eax
80106881:	83 f8 1f             	cmp    $0x1f,%eax
80106884:	0f 87 ae 00 00 00    	ja     80106938 <trap+0x113>
8010688a:	8b 04 85 b4 8a 10 80 	mov    -0x7fef754c(,%eax,4),%eax
80106891:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpunum() == 0){
80106893:	e8 59 c6 ff ff       	call   80102ef1 <cpunum>
80106898:	85 c0                	test   %eax,%eax
8010689a:	75 2f                	jne    801068cb <trap+0xa6>
      acquire(&tickslock);
8010689c:	c7 04 24 80 5d 11 80 	movl   $0x80115d80,(%esp)
801068a3:	e8 7f e6 ff ff       	call   80104f27 <acquire>
      ticks++;
801068a8:	a1 c0 65 11 80       	mov    0x801165c0,%eax
801068ad:	40                   	inc    %eax
801068ae:	a3 c0 65 11 80       	mov    %eax,0x801165c0
      wakeup(&ticks);
801068b3:	c7 04 24 c0 65 11 80 	movl   $0x801165c0,(%esp)
801068ba:	e8 70 e3 ff ff       	call   80104c2f <wakeup>
      release(&tickslock);
801068bf:	c7 04 24 80 5d 11 80 	movl   $0x80115d80,(%esp)
801068c6:	e8 c3 e6 ff ff       	call   80104f8e <release>
    }
    lapiceoi();
801068cb:	e8 c9 c6 ff ff       	call   80102f99 <lapiceoi>
    break;
801068d0:	e9 2d 01 00 00       	jmp    80106a02 <trap+0x1dd>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801068d5:	e8 90 be ff ff       	call   8010276a <ideintr>
    lapiceoi();
801068da:	e8 ba c6 ff ff       	call   80102f99 <lapiceoi>
    break;
801068df:	e9 1e 01 00 00       	jmp    80106a02 <trap+0x1dd>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801068e4:	e8 31 c4 ff ff       	call   80102d1a <kbdintr>
    lapiceoi();
801068e9:	e8 ab c6 ff ff       	call   80102f99 <lapiceoi>
    break;
801068ee:	e9 0f 01 00 00       	jmp    80106a02 <trap+0x1dd>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801068f3:	e8 79 03 00 00       	call   80106c71 <uartintr>
    lapiceoi();
801068f8:	e8 9c c6 ff ff       	call   80102f99 <lapiceoi>
    break;
801068fd:	e9 00 01 00 00       	jmp    80106a02 <trap+0x1dd>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106902:	8b 45 08             	mov    0x8(%ebp),%eax
80106905:	8b 70 38             	mov    0x38(%eax),%esi
            cpunum(), tf->cs, tf->eip);
80106908:	8b 45 08             	mov    0x8(%ebp),%eax
8010690b:	8b 40 3c             	mov    0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010690e:	0f b7 d8             	movzwl %ax,%ebx
80106911:	e8 db c5 ff ff       	call   80102ef1 <cpunum>
80106916:	89 74 24 0c          	mov    %esi,0xc(%esp)
8010691a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
8010691e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106922:	c7 04 24 14 8a 10 80 	movl   $0x80108a14,(%esp)
80106929:	e8 93 9a ff ff       	call   801003c1 <cprintf>
            cpunum(), tf->cs, tf->eip);
    lapiceoi();
8010692e:	e8 66 c6 ff ff       	call   80102f99 <lapiceoi>
    break;
80106933:	e9 ca 00 00 00       	jmp    80106a02 <trap+0x1dd>

  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106938:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010693e:	85 c0                	test   %eax,%eax
80106940:	74 10                	je     80106952 <trap+0x12d>
80106942:	8b 45 08             	mov    0x8(%ebp),%eax
80106945:	8b 40 3c             	mov    0x3c(%eax),%eax
80106948:	0f b7 c0             	movzwl %ax,%eax
8010694b:	83 e0 03             	and    $0x3,%eax
8010694e:	85 c0                	test   %eax,%eax
80106950:	75 40                	jne    80106992 <trap+0x16d>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106952:	e8 44 fd ff ff       	call   8010669b <rcr2>
80106957:	89 c3                	mov    %eax,%ebx
80106959:	8b 45 08             	mov    0x8(%ebp),%eax
8010695c:	8b 70 38             	mov    0x38(%eax),%esi
8010695f:	e8 8d c5 ff ff       	call   80102ef1 <cpunum>
80106964:	8b 55 08             	mov    0x8(%ebp),%edx
80106967:	8b 52 30             	mov    0x30(%edx),%edx
8010696a:	89 5c 24 10          	mov    %ebx,0x10(%esp)
8010696e:	89 74 24 0c          	mov    %esi,0xc(%esp)
80106972:	89 44 24 08          	mov    %eax,0x8(%esp)
80106976:	89 54 24 04          	mov    %edx,0x4(%esp)
8010697a:	c7 04 24 38 8a 10 80 	movl   $0x80108a38,(%esp)
80106981:	e8 3b 9a ff ff       	call   801003c1 <cprintf>
              tf->trapno, cpunum(), tf->eip, rcr2());
      panic("trap");
80106986:	c7 04 24 6a 8a 10 80 	movl   $0x80108a6a,(%esp)
8010698d:	e8 c2 9b ff ff       	call   80100554 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106992:	e8 04 fd ff ff       	call   8010669b <rcr2>
80106997:	89 c3                	mov    %eax,%ebx
80106999:	8b 45 08             	mov    0x8(%ebp),%eax
8010699c:	8b 78 38             	mov    0x38(%eax),%edi
8010699f:	e8 4d c5 ff ff       	call   80102ef1 <cpunum>
801069a4:	89 c2                	mov    %eax,%edx
801069a6:	8b 45 08             	mov    0x8(%ebp),%eax
801069a9:	8b 70 34             	mov    0x34(%eax),%esi
801069ac:	8b 45 08             	mov    0x8(%ebp),%eax
801069af:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpunum(), tf->eip,
801069b2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801069b8:	83 c0 6c             	add    $0x6c,%eax
801069bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801069be:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpunum(), tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801069c4:	8b 40 10             	mov    0x10(%eax),%eax
801069c7:	89 5c 24 1c          	mov    %ebx,0x1c(%esp)
801069cb:	89 7c 24 18          	mov    %edi,0x18(%esp)
801069cf:	89 54 24 14          	mov    %edx,0x14(%esp)
801069d3:	89 74 24 10          	mov    %esi,0x10(%esp)
801069d7:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801069db:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801069de:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801069e2:	89 44 24 04          	mov    %eax,0x4(%esp)
801069e6:	c7 04 24 70 8a 10 80 	movl   $0x80108a70,(%esp)
801069ed:	e8 cf 99 ff ff       	call   801003c1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpunum(), tf->eip,
            rcr2());
    proc->killed = 1;
801069f2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801069f8:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801069ff:	eb 01                	jmp    80106a02 <trap+0x1dd>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106a01:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106a02:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a08:	85 c0                	test   %eax,%eax
80106a0a:	74 23                	je     80106a2f <trap+0x20a>
80106a0c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a12:	8b 40 24             	mov    0x24(%eax),%eax
80106a15:	85 c0                	test   %eax,%eax
80106a17:	74 16                	je     80106a2f <trap+0x20a>
80106a19:	8b 45 08             	mov    0x8(%ebp),%eax
80106a1c:	8b 40 3c             	mov    0x3c(%eax),%eax
80106a1f:	0f b7 c0             	movzwl %ax,%eax
80106a22:	83 e0 03             	and    $0x3,%eax
80106a25:	83 f8 03             	cmp    $0x3,%eax
80106a28:	75 05                	jne    80106a2f <trap+0x20a>
    exit();
80106a2a:	e8 3f dd ff ff       	call   8010476e <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106a2f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a35:	85 c0                	test   %eax,%eax
80106a37:	74 1e                	je     80106a57 <trap+0x232>
80106a39:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a3f:	8b 40 0c             	mov    0xc(%eax),%eax
80106a42:	83 f8 04             	cmp    $0x4,%eax
80106a45:	75 10                	jne    80106a57 <trap+0x232>
80106a47:	8b 45 08             	mov    0x8(%ebp),%eax
80106a4a:	8b 40 30             	mov    0x30(%eax),%eax
80106a4d:	83 f8 20             	cmp    $0x20,%eax
80106a50:	75 05                	jne    80106a57 <trap+0x232>
    yield();
80106a52:	e8 8e e0 ff ff       	call   80104ae5 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106a57:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a5d:	85 c0                	test   %eax,%eax
80106a5f:	74 23                	je     80106a84 <trap+0x25f>
80106a61:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a67:	8b 40 24             	mov    0x24(%eax),%eax
80106a6a:	85 c0                	test   %eax,%eax
80106a6c:	74 16                	je     80106a84 <trap+0x25f>
80106a6e:	8b 45 08             	mov    0x8(%ebp),%eax
80106a71:	8b 40 3c             	mov    0x3c(%eax),%eax
80106a74:	0f b7 c0             	movzwl %ax,%eax
80106a77:	83 e0 03             	and    $0x3,%eax
80106a7a:	83 f8 03             	cmp    $0x3,%eax
80106a7d:	75 05                	jne    80106a84 <trap+0x25f>
    exit();
80106a7f:	e8 ea dc ff ff       	call   8010476e <exit>
}
80106a84:	83 c4 3c             	add    $0x3c,%esp
80106a87:	5b                   	pop    %ebx
80106a88:	5e                   	pop    %esi
80106a89:	5f                   	pop    %edi
80106a8a:	5d                   	pop    %ebp
80106a8b:	c3                   	ret    

80106a8c <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106a8c:	55                   	push   %ebp
80106a8d:	89 e5                	mov    %esp,%ebp
80106a8f:	83 ec 14             	sub    $0x14,%esp
80106a92:	8b 45 08             	mov    0x8(%ebp),%eax
80106a95:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106a99:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106a9c:	89 c2                	mov    %eax,%edx
80106a9e:	ec                   	in     (%dx),%al
80106a9f:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106aa2:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80106aa5:	c9                   	leave  
80106aa6:	c3                   	ret    

80106aa7 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106aa7:	55                   	push   %ebp
80106aa8:	89 e5                	mov    %esp,%ebp
80106aaa:	83 ec 08             	sub    $0x8,%esp
80106aad:	8b 45 08             	mov    0x8(%ebp),%eax
80106ab0:	8b 55 0c             	mov    0xc(%ebp),%edx
80106ab3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106ab7:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106aba:	8a 45 f8             	mov    -0x8(%ebp),%al
80106abd:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106ac0:	ee                   	out    %al,(%dx)
}
80106ac1:	c9                   	leave  
80106ac2:	c3                   	ret    

80106ac3 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106ac3:	55                   	push   %ebp
80106ac4:	89 e5                	mov    %esp,%ebp
80106ac6:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106ac9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106ad0:	00 
80106ad1:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106ad8:	e8 ca ff ff ff       	call   80106aa7 <outb>

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106add:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80106ae4:	00 
80106ae5:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106aec:	e8 b6 ff ff ff       	call   80106aa7 <outb>
  outb(COM1+0, 115200/9600);
80106af1:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80106af8:	00 
80106af9:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106b00:	e8 a2 ff ff ff       	call   80106aa7 <outb>
  outb(COM1+1, 0);
80106b05:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106b0c:	00 
80106b0d:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106b14:	e8 8e ff ff ff       	call   80106aa7 <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106b19:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106b20:	00 
80106b21:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106b28:	e8 7a ff ff ff       	call   80106aa7 <outb>
  outb(COM1+4, 0);
80106b2d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106b34:	00 
80106b35:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80106b3c:	e8 66 ff ff ff       	call   80106aa7 <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106b41:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106b48:	00 
80106b49:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106b50:	e8 52 ff ff ff       	call   80106aa7 <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106b55:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106b5c:	e8 2b ff ff ff       	call   80106a8c <inb>
80106b61:	3c ff                	cmp    $0xff,%al
80106b63:	75 02                	jne    80106b67 <uartinit+0xa4>
    return;
80106b65:	eb 67                	jmp    80106bce <uartinit+0x10b>
  uart = 1;
80106b67:	c7 05 68 b6 10 80 01 	movl   $0x1,0x8010b668
80106b6e:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106b71:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106b78:	e8 0f ff ff ff       	call   80106a8c <inb>
  inb(COM1+0);
80106b7d:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106b84:	e8 03 ff ff ff       	call   80106a8c <inb>
  picenable(IRQ_COM1);
80106b89:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106b90:	e8 ef d1 ff ff       	call   80103d84 <picenable>
  ioapicenable(IRQ_COM1, 0);
80106b95:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106b9c:	00 
80106b9d:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106ba4:	e8 44 be ff ff       	call   801029ed <ioapicenable>

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106ba9:	c7 45 f4 34 8b 10 80 	movl   $0x80108b34,-0xc(%ebp)
80106bb0:	eb 13                	jmp    80106bc5 <uartinit+0x102>
    uartputc(*p);
80106bb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bb5:	8a 00                	mov    (%eax),%al
80106bb7:	0f be c0             	movsbl %al,%eax
80106bba:	89 04 24             	mov    %eax,(%esp)
80106bbd:	e8 0e 00 00 00       	call   80106bd0 <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106bc2:	ff 45 f4             	incl   -0xc(%ebp)
80106bc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bc8:	8a 00                	mov    (%eax),%al
80106bca:	84 c0                	test   %al,%al
80106bcc:	75 e4                	jne    80106bb2 <uartinit+0xef>
    uartputc(*p);
}
80106bce:	c9                   	leave  
80106bcf:	c3                   	ret    

80106bd0 <uartputc>:

void
uartputc(int c)
{
80106bd0:	55                   	push   %ebp
80106bd1:	89 e5                	mov    %esp,%ebp
80106bd3:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80106bd6:	a1 68 b6 10 80       	mov    0x8010b668,%eax
80106bdb:	85 c0                	test   %eax,%eax
80106bdd:	75 02                	jne    80106be1 <uartputc+0x11>
    return;
80106bdf:	eb 4a                	jmp    80106c2b <uartputc+0x5b>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106be1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106be8:	eb 0f                	jmp    80106bf9 <uartputc+0x29>
    microdelay(10);
80106bea:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80106bf1:	e8 c8 c3 ff ff       	call   80102fbe <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106bf6:	ff 45 f4             	incl   -0xc(%ebp)
80106bf9:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106bfd:	7f 16                	jg     80106c15 <uartputc+0x45>
80106bff:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106c06:	e8 81 fe ff ff       	call   80106a8c <inb>
80106c0b:	0f b6 c0             	movzbl %al,%eax
80106c0e:	83 e0 20             	and    $0x20,%eax
80106c11:	85 c0                	test   %eax,%eax
80106c13:	74 d5                	je     80106bea <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
80106c15:	8b 45 08             	mov    0x8(%ebp),%eax
80106c18:	0f b6 c0             	movzbl %al,%eax
80106c1b:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c1f:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106c26:	e8 7c fe ff ff       	call   80106aa7 <outb>
}
80106c2b:	c9                   	leave  
80106c2c:	c3                   	ret    

80106c2d <uartgetc>:

static int
uartgetc(void)
{
80106c2d:	55                   	push   %ebp
80106c2e:	89 e5                	mov    %esp,%ebp
80106c30:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80106c33:	a1 68 b6 10 80       	mov    0x8010b668,%eax
80106c38:	85 c0                	test   %eax,%eax
80106c3a:	75 07                	jne    80106c43 <uartgetc+0x16>
    return -1;
80106c3c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c41:	eb 2c                	jmp    80106c6f <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80106c43:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106c4a:	e8 3d fe ff ff       	call   80106a8c <inb>
80106c4f:	0f b6 c0             	movzbl %al,%eax
80106c52:	83 e0 01             	and    $0x1,%eax
80106c55:	85 c0                	test   %eax,%eax
80106c57:	75 07                	jne    80106c60 <uartgetc+0x33>
    return -1;
80106c59:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c5e:	eb 0f                	jmp    80106c6f <uartgetc+0x42>
  return inb(COM1+0);
80106c60:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106c67:	e8 20 fe ff ff       	call   80106a8c <inb>
80106c6c:	0f b6 c0             	movzbl %al,%eax
}
80106c6f:	c9                   	leave  
80106c70:	c3                   	ret    

80106c71 <uartintr>:

void
uartintr(void)
{
80106c71:	55                   	push   %ebp
80106c72:	89 e5                	mov    %esp,%ebp
80106c74:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80106c77:	c7 04 24 2d 6c 10 80 	movl   $0x80106c2d,(%esp)
80106c7e:	e8 48 9b ff ff       	call   801007cb <consoleintr>
}
80106c83:	c9                   	leave  
80106c84:	c3                   	ret    
80106c85:	00 00                	add    %al,(%eax)
	...

80106c88 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106c88:	6a 00                	push   $0x0
  pushl $0
80106c8a:	6a 00                	push   $0x0
  jmp alltraps
80106c8c:	e9 b7 f9 ff ff       	jmp    80106648 <alltraps>

80106c91 <vector1>:
.globl vector1
vector1:
  pushl $0
80106c91:	6a 00                	push   $0x0
  pushl $1
80106c93:	6a 01                	push   $0x1
  jmp alltraps
80106c95:	e9 ae f9 ff ff       	jmp    80106648 <alltraps>

80106c9a <vector2>:
.globl vector2
vector2:
  pushl $0
80106c9a:	6a 00                	push   $0x0
  pushl $2
80106c9c:	6a 02                	push   $0x2
  jmp alltraps
80106c9e:	e9 a5 f9 ff ff       	jmp    80106648 <alltraps>

80106ca3 <vector3>:
.globl vector3
vector3:
  pushl $0
80106ca3:	6a 00                	push   $0x0
  pushl $3
80106ca5:	6a 03                	push   $0x3
  jmp alltraps
80106ca7:	e9 9c f9 ff ff       	jmp    80106648 <alltraps>

80106cac <vector4>:
.globl vector4
vector4:
  pushl $0
80106cac:	6a 00                	push   $0x0
  pushl $4
80106cae:	6a 04                	push   $0x4
  jmp alltraps
80106cb0:	e9 93 f9 ff ff       	jmp    80106648 <alltraps>

80106cb5 <vector5>:
.globl vector5
vector5:
  pushl $0
80106cb5:	6a 00                	push   $0x0
  pushl $5
80106cb7:	6a 05                	push   $0x5
  jmp alltraps
80106cb9:	e9 8a f9 ff ff       	jmp    80106648 <alltraps>

80106cbe <vector6>:
.globl vector6
vector6:
  pushl $0
80106cbe:	6a 00                	push   $0x0
  pushl $6
80106cc0:	6a 06                	push   $0x6
  jmp alltraps
80106cc2:	e9 81 f9 ff ff       	jmp    80106648 <alltraps>

80106cc7 <vector7>:
.globl vector7
vector7:
  pushl $0
80106cc7:	6a 00                	push   $0x0
  pushl $7
80106cc9:	6a 07                	push   $0x7
  jmp alltraps
80106ccb:	e9 78 f9 ff ff       	jmp    80106648 <alltraps>

80106cd0 <vector8>:
.globl vector8
vector8:
  pushl $8
80106cd0:	6a 08                	push   $0x8
  jmp alltraps
80106cd2:	e9 71 f9 ff ff       	jmp    80106648 <alltraps>

80106cd7 <vector9>:
.globl vector9
vector9:
  pushl $0
80106cd7:	6a 00                	push   $0x0
  pushl $9
80106cd9:	6a 09                	push   $0x9
  jmp alltraps
80106cdb:	e9 68 f9 ff ff       	jmp    80106648 <alltraps>

80106ce0 <vector10>:
.globl vector10
vector10:
  pushl $10
80106ce0:	6a 0a                	push   $0xa
  jmp alltraps
80106ce2:	e9 61 f9 ff ff       	jmp    80106648 <alltraps>

80106ce7 <vector11>:
.globl vector11
vector11:
  pushl $11
80106ce7:	6a 0b                	push   $0xb
  jmp alltraps
80106ce9:	e9 5a f9 ff ff       	jmp    80106648 <alltraps>

80106cee <vector12>:
.globl vector12
vector12:
  pushl $12
80106cee:	6a 0c                	push   $0xc
  jmp alltraps
80106cf0:	e9 53 f9 ff ff       	jmp    80106648 <alltraps>

80106cf5 <vector13>:
.globl vector13
vector13:
  pushl $13
80106cf5:	6a 0d                	push   $0xd
  jmp alltraps
80106cf7:	e9 4c f9 ff ff       	jmp    80106648 <alltraps>

80106cfc <vector14>:
.globl vector14
vector14:
  pushl $14
80106cfc:	6a 0e                	push   $0xe
  jmp alltraps
80106cfe:	e9 45 f9 ff ff       	jmp    80106648 <alltraps>

80106d03 <vector15>:
.globl vector15
vector15:
  pushl $0
80106d03:	6a 00                	push   $0x0
  pushl $15
80106d05:	6a 0f                	push   $0xf
  jmp alltraps
80106d07:	e9 3c f9 ff ff       	jmp    80106648 <alltraps>

80106d0c <vector16>:
.globl vector16
vector16:
  pushl $0
80106d0c:	6a 00                	push   $0x0
  pushl $16
80106d0e:	6a 10                	push   $0x10
  jmp alltraps
80106d10:	e9 33 f9 ff ff       	jmp    80106648 <alltraps>

80106d15 <vector17>:
.globl vector17
vector17:
  pushl $17
80106d15:	6a 11                	push   $0x11
  jmp alltraps
80106d17:	e9 2c f9 ff ff       	jmp    80106648 <alltraps>

80106d1c <vector18>:
.globl vector18
vector18:
  pushl $0
80106d1c:	6a 00                	push   $0x0
  pushl $18
80106d1e:	6a 12                	push   $0x12
  jmp alltraps
80106d20:	e9 23 f9 ff ff       	jmp    80106648 <alltraps>

80106d25 <vector19>:
.globl vector19
vector19:
  pushl $0
80106d25:	6a 00                	push   $0x0
  pushl $19
80106d27:	6a 13                	push   $0x13
  jmp alltraps
80106d29:	e9 1a f9 ff ff       	jmp    80106648 <alltraps>

80106d2e <vector20>:
.globl vector20
vector20:
  pushl $0
80106d2e:	6a 00                	push   $0x0
  pushl $20
80106d30:	6a 14                	push   $0x14
  jmp alltraps
80106d32:	e9 11 f9 ff ff       	jmp    80106648 <alltraps>

80106d37 <vector21>:
.globl vector21
vector21:
  pushl $0
80106d37:	6a 00                	push   $0x0
  pushl $21
80106d39:	6a 15                	push   $0x15
  jmp alltraps
80106d3b:	e9 08 f9 ff ff       	jmp    80106648 <alltraps>

80106d40 <vector22>:
.globl vector22
vector22:
  pushl $0
80106d40:	6a 00                	push   $0x0
  pushl $22
80106d42:	6a 16                	push   $0x16
  jmp alltraps
80106d44:	e9 ff f8 ff ff       	jmp    80106648 <alltraps>

80106d49 <vector23>:
.globl vector23
vector23:
  pushl $0
80106d49:	6a 00                	push   $0x0
  pushl $23
80106d4b:	6a 17                	push   $0x17
  jmp alltraps
80106d4d:	e9 f6 f8 ff ff       	jmp    80106648 <alltraps>

80106d52 <vector24>:
.globl vector24
vector24:
  pushl $0
80106d52:	6a 00                	push   $0x0
  pushl $24
80106d54:	6a 18                	push   $0x18
  jmp alltraps
80106d56:	e9 ed f8 ff ff       	jmp    80106648 <alltraps>

80106d5b <vector25>:
.globl vector25
vector25:
  pushl $0
80106d5b:	6a 00                	push   $0x0
  pushl $25
80106d5d:	6a 19                	push   $0x19
  jmp alltraps
80106d5f:	e9 e4 f8 ff ff       	jmp    80106648 <alltraps>

80106d64 <vector26>:
.globl vector26
vector26:
  pushl $0
80106d64:	6a 00                	push   $0x0
  pushl $26
80106d66:	6a 1a                	push   $0x1a
  jmp alltraps
80106d68:	e9 db f8 ff ff       	jmp    80106648 <alltraps>

80106d6d <vector27>:
.globl vector27
vector27:
  pushl $0
80106d6d:	6a 00                	push   $0x0
  pushl $27
80106d6f:	6a 1b                	push   $0x1b
  jmp alltraps
80106d71:	e9 d2 f8 ff ff       	jmp    80106648 <alltraps>

80106d76 <vector28>:
.globl vector28
vector28:
  pushl $0
80106d76:	6a 00                	push   $0x0
  pushl $28
80106d78:	6a 1c                	push   $0x1c
  jmp alltraps
80106d7a:	e9 c9 f8 ff ff       	jmp    80106648 <alltraps>

80106d7f <vector29>:
.globl vector29
vector29:
  pushl $0
80106d7f:	6a 00                	push   $0x0
  pushl $29
80106d81:	6a 1d                	push   $0x1d
  jmp alltraps
80106d83:	e9 c0 f8 ff ff       	jmp    80106648 <alltraps>

80106d88 <vector30>:
.globl vector30
vector30:
  pushl $0
80106d88:	6a 00                	push   $0x0
  pushl $30
80106d8a:	6a 1e                	push   $0x1e
  jmp alltraps
80106d8c:	e9 b7 f8 ff ff       	jmp    80106648 <alltraps>

80106d91 <vector31>:
.globl vector31
vector31:
  pushl $0
80106d91:	6a 00                	push   $0x0
  pushl $31
80106d93:	6a 1f                	push   $0x1f
  jmp alltraps
80106d95:	e9 ae f8 ff ff       	jmp    80106648 <alltraps>

80106d9a <vector32>:
.globl vector32
vector32:
  pushl $0
80106d9a:	6a 00                	push   $0x0
  pushl $32
80106d9c:	6a 20                	push   $0x20
  jmp alltraps
80106d9e:	e9 a5 f8 ff ff       	jmp    80106648 <alltraps>

80106da3 <vector33>:
.globl vector33
vector33:
  pushl $0
80106da3:	6a 00                	push   $0x0
  pushl $33
80106da5:	6a 21                	push   $0x21
  jmp alltraps
80106da7:	e9 9c f8 ff ff       	jmp    80106648 <alltraps>

80106dac <vector34>:
.globl vector34
vector34:
  pushl $0
80106dac:	6a 00                	push   $0x0
  pushl $34
80106dae:	6a 22                	push   $0x22
  jmp alltraps
80106db0:	e9 93 f8 ff ff       	jmp    80106648 <alltraps>

80106db5 <vector35>:
.globl vector35
vector35:
  pushl $0
80106db5:	6a 00                	push   $0x0
  pushl $35
80106db7:	6a 23                	push   $0x23
  jmp alltraps
80106db9:	e9 8a f8 ff ff       	jmp    80106648 <alltraps>

80106dbe <vector36>:
.globl vector36
vector36:
  pushl $0
80106dbe:	6a 00                	push   $0x0
  pushl $36
80106dc0:	6a 24                	push   $0x24
  jmp alltraps
80106dc2:	e9 81 f8 ff ff       	jmp    80106648 <alltraps>

80106dc7 <vector37>:
.globl vector37
vector37:
  pushl $0
80106dc7:	6a 00                	push   $0x0
  pushl $37
80106dc9:	6a 25                	push   $0x25
  jmp alltraps
80106dcb:	e9 78 f8 ff ff       	jmp    80106648 <alltraps>

80106dd0 <vector38>:
.globl vector38
vector38:
  pushl $0
80106dd0:	6a 00                	push   $0x0
  pushl $38
80106dd2:	6a 26                	push   $0x26
  jmp alltraps
80106dd4:	e9 6f f8 ff ff       	jmp    80106648 <alltraps>

80106dd9 <vector39>:
.globl vector39
vector39:
  pushl $0
80106dd9:	6a 00                	push   $0x0
  pushl $39
80106ddb:	6a 27                	push   $0x27
  jmp alltraps
80106ddd:	e9 66 f8 ff ff       	jmp    80106648 <alltraps>

80106de2 <vector40>:
.globl vector40
vector40:
  pushl $0
80106de2:	6a 00                	push   $0x0
  pushl $40
80106de4:	6a 28                	push   $0x28
  jmp alltraps
80106de6:	e9 5d f8 ff ff       	jmp    80106648 <alltraps>

80106deb <vector41>:
.globl vector41
vector41:
  pushl $0
80106deb:	6a 00                	push   $0x0
  pushl $41
80106ded:	6a 29                	push   $0x29
  jmp alltraps
80106def:	e9 54 f8 ff ff       	jmp    80106648 <alltraps>

80106df4 <vector42>:
.globl vector42
vector42:
  pushl $0
80106df4:	6a 00                	push   $0x0
  pushl $42
80106df6:	6a 2a                	push   $0x2a
  jmp alltraps
80106df8:	e9 4b f8 ff ff       	jmp    80106648 <alltraps>

80106dfd <vector43>:
.globl vector43
vector43:
  pushl $0
80106dfd:	6a 00                	push   $0x0
  pushl $43
80106dff:	6a 2b                	push   $0x2b
  jmp alltraps
80106e01:	e9 42 f8 ff ff       	jmp    80106648 <alltraps>

80106e06 <vector44>:
.globl vector44
vector44:
  pushl $0
80106e06:	6a 00                	push   $0x0
  pushl $44
80106e08:	6a 2c                	push   $0x2c
  jmp alltraps
80106e0a:	e9 39 f8 ff ff       	jmp    80106648 <alltraps>

80106e0f <vector45>:
.globl vector45
vector45:
  pushl $0
80106e0f:	6a 00                	push   $0x0
  pushl $45
80106e11:	6a 2d                	push   $0x2d
  jmp alltraps
80106e13:	e9 30 f8 ff ff       	jmp    80106648 <alltraps>

80106e18 <vector46>:
.globl vector46
vector46:
  pushl $0
80106e18:	6a 00                	push   $0x0
  pushl $46
80106e1a:	6a 2e                	push   $0x2e
  jmp alltraps
80106e1c:	e9 27 f8 ff ff       	jmp    80106648 <alltraps>

80106e21 <vector47>:
.globl vector47
vector47:
  pushl $0
80106e21:	6a 00                	push   $0x0
  pushl $47
80106e23:	6a 2f                	push   $0x2f
  jmp alltraps
80106e25:	e9 1e f8 ff ff       	jmp    80106648 <alltraps>

80106e2a <vector48>:
.globl vector48
vector48:
  pushl $0
80106e2a:	6a 00                	push   $0x0
  pushl $48
80106e2c:	6a 30                	push   $0x30
  jmp alltraps
80106e2e:	e9 15 f8 ff ff       	jmp    80106648 <alltraps>

80106e33 <vector49>:
.globl vector49
vector49:
  pushl $0
80106e33:	6a 00                	push   $0x0
  pushl $49
80106e35:	6a 31                	push   $0x31
  jmp alltraps
80106e37:	e9 0c f8 ff ff       	jmp    80106648 <alltraps>

80106e3c <vector50>:
.globl vector50
vector50:
  pushl $0
80106e3c:	6a 00                	push   $0x0
  pushl $50
80106e3e:	6a 32                	push   $0x32
  jmp alltraps
80106e40:	e9 03 f8 ff ff       	jmp    80106648 <alltraps>

80106e45 <vector51>:
.globl vector51
vector51:
  pushl $0
80106e45:	6a 00                	push   $0x0
  pushl $51
80106e47:	6a 33                	push   $0x33
  jmp alltraps
80106e49:	e9 fa f7 ff ff       	jmp    80106648 <alltraps>

80106e4e <vector52>:
.globl vector52
vector52:
  pushl $0
80106e4e:	6a 00                	push   $0x0
  pushl $52
80106e50:	6a 34                	push   $0x34
  jmp alltraps
80106e52:	e9 f1 f7 ff ff       	jmp    80106648 <alltraps>

80106e57 <vector53>:
.globl vector53
vector53:
  pushl $0
80106e57:	6a 00                	push   $0x0
  pushl $53
80106e59:	6a 35                	push   $0x35
  jmp alltraps
80106e5b:	e9 e8 f7 ff ff       	jmp    80106648 <alltraps>

80106e60 <vector54>:
.globl vector54
vector54:
  pushl $0
80106e60:	6a 00                	push   $0x0
  pushl $54
80106e62:	6a 36                	push   $0x36
  jmp alltraps
80106e64:	e9 df f7 ff ff       	jmp    80106648 <alltraps>

80106e69 <vector55>:
.globl vector55
vector55:
  pushl $0
80106e69:	6a 00                	push   $0x0
  pushl $55
80106e6b:	6a 37                	push   $0x37
  jmp alltraps
80106e6d:	e9 d6 f7 ff ff       	jmp    80106648 <alltraps>

80106e72 <vector56>:
.globl vector56
vector56:
  pushl $0
80106e72:	6a 00                	push   $0x0
  pushl $56
80106e74:	6a 38                	push   $0x38
  jmp alltraps
80106e76:	e9 cd f7 ff ff       	jmp    80106648 <alltraps>

80106e7b <vector57>:
.globl vector57
vector57:
  pushl $0
80106e7b:	6a 00                	push   $0x0
  pushl $57
80106e7d:	6a 39                	push   $0x39
  jmp alltraps
80106e7f:	e9 c4 f7 ff ff       	jmp    80106648 <alltraps>

80106e84 <vector58>:
.globl vector58
vector58:
  pushl $0
80106e84:	6a 00                	push   $0x0
  pushl $58
80106e86:	6a 3a                	push   $0x3a
  jmp alltraps
80106e88:	e9 bb f7 ff ff       	jmp    80106648 <alltraps>

80106e8d <vector59>:
.globl vector59
vector59:
  pushl $0
80106e8d:	6a 00                	push   $0x0
  pushl $59
80106e8f:	6a 3b                	push   $0x3b
  jmp alltraps
80106e91:	e9 b2 f7 ff ff       	jmp    80106648 <alltraps>

80106e96 <vector60>:
.globl vector60
vector60:
  pushl $0
80106e96:	6a 00                	push   $0x0
  pushl $60
80106e98:	6a 3c                	push   $0x3c
  jmp alltraps
80106e9a:	e9 a9 f7 ff ff       	jmp    80106648 <alltraps>

80106e9f <vector61>:
.globl vector61
vector61:
  pushl $0
80106e9f:	6a 00                	push   $0x0
  pushl $61
80106ea1:	6a 3d                	push   $0x3d
  jmp alltraps
80106ea3:	e9 a0 f7 ff ff       	jmp    80106648 <alltraps>

80106ea8 <vector62>:
.globl vector62
vector62:
  pushl $0
80106ea8:	6a 00                	push   $0x0
  pushl $62
80106eaa:	6a 3e                	push   $0x3e
  jmp alltraps
80106eac:	e9 97 f7 ff ff       	jmp    80106648 <alltraps>

80106eb1 <vector63>:
.globl vector63
vector63:
  pushl $0
80106eb1:	6a 00                	push   $0x0
  pushl $63
80106eb3:	6a 3f                	push   $0x3f
  jmp alltraps
80106eb5:	e9 8e f7 ff ff       	jmp    80106648 <alltraps>

80106eba <vector64>:
.globl vector64
vector64:
  pushl $0
80106eba:	6a 00                	push   $0x0
  pushl $64
80106ebc:	6a 40                	push   $0x40
  jmp alltraps
80106ebe:	e9 85 f7 ff ff       	jmp    80106648 <alltraps>

80106ec3 <vector65>:
.globl vector65
vector65:
  pushl $0
80106ec3:	6a 00                	push   $0x0
  pushl $65
80106ec5:	6a 41                	push   $0x41
  jmp alltraps
80106ec7:	e9 7c f7 ff ff       	jmp    80106648 <alltraps>

80106ecc <vector66>:
.globl vector66
vector66:
  pushl $0
80106ecc:	6a 00                	push   $0x0
  pushl $66
80106ece:	6a 42                	push   $0x42
  jmp alltraps
80106ed0:	e9 73 f7 ff ff       	jmp    80106648 <alltraps>

80106ed5 <vector67>:
.globl vector67
vector67:
  pushl $0
80106ed5:	6a 00                	push   $0x0
  pushl $67
80106ed7:	6a 43                	push   $0x43
  jmp alltraps
80106ed9:	e9 6a f7 ff ff       	jmp    80106648 <alltraps>

80106ede <vector68>:
.globl vector68
vector68:
  pushl $0
80106ede:	6a 00                	push   $0x0
  pushl $68
80106ee0:	6a 44                	push   $0x44
  jmp alltraps
80106ee2:	e9 61 f7 ff ff       	jmp    80106648 <alltraps>

80106ee7 <vector69>:
.globl vector69
vector69:
  pushl $0
80106ee7:	6a 00                	push   $0x0
  pushl $69
80106ee9:	6a 45                	push   $0x45
  jmp alltraps
80106eeb:	e9 58 f7 ff ff       	jmp    80106648 <alltraps>

80106ef0 <vector70>:
.globl vector70
vector70:
  pushl $0
80106ef0:	6a 00                	push   $0x0
  pushl $70
80106ef2:	6a 46                	push   $0x46
  jmp alltraps
80106ef4:	e9 4f f7 ff ff       	jmp    80106648 <alltraps>

80106ef9 <vector71>:
.globl vector71
vector71:
  pushl $0
80106ef9:	6a 00                	push   $0x0
  pushl $71
80106efb:	6a 47                	push   $0x47
  jmp alltraps
80106efd:	e9 46 f7 ff ff       	jmp    80106648 <alltraps>

80106f02 <vector72>:
.globl vector72
vector72:
  pushl $0
80106f02:	6a 00                	push   $0x0
  pushl $72
80106f04:	6a 48                	push   $0x48
  jmp alltraps
80106f06:	e9 3d f7 ff ff       	jmp    80106648 <alltraps>

80106f0b <vector73>:
.globl vector73
vector73:
  pushl $0
80106f0b:	6a 00                	push   $0x0
  pushl $73
80106f0d:	6a 49                	push   $0x49
  jmp alltraps
80106f0f:	e9 34 f7 ff ff       	jmp    80106648 <alltraps>

80106f14 <vector74>:
.globl vector74
vector74:
  pushl $0
80106f14:	6a 00                	push   $0x0
  pushl $74
80106f16:	6a 4a                	push   $0x4a
  jmp alltraps
80106f18:	e9 2b f7 ff ff       	jmp    80106648 <alltraps>

80106f1d <vector75>:
.globl vector75
vector75:
  pushl $0
80106f1d:	6a 00                	push   $0x0
  pushl $75
80106f1f:	6a 4b                	push   $0x4b
  jmp alltraps
80106f21:	e9 22 f7 ff ff       	jmp    80106648 <alltraps>

80106f26 <vector76>:
.globl vector76
vector76:
  pushl $0
80106f26:	6a 00                	push   $0x0
  pushl $76
80106f28:	6a 4c                	push   $0x4c
  jmp alltraps
80106f2a:	e9 19 f7 ff ff       	jmp    80106648 <alltraps>

80106f2f <vector77>:
.globl vector77
vector77:
  pushl $0
80106f2f:	6a 00                	push   $0x0
  pushl $77
80106f31:	6a 4d                	push   $0x4d
  jmp alltraps
80106f33:	e9 10 f7 ff ff       	jmp    80106648 <alltraps>

80106f38 <vector78>:
.globl vector78
vector78:
  pushl $0
80106f38:	6a 00                	push   $0x0
  pushl $78
80106f3a:	6a 4e                	push   $0x4e
  jmp alltraps
80106f3c:	e9 07 f7 ff ff       	jmp    80106648 <alltraps>

80106f41 <vector79>:
.globl vector79
vector79:
  pushl $0
80106f41:	6a 00                	push   $0x0
  pushl $79
80106f43:	6a 4f                	push   $0x4f
  jmp alltraps
80106f45:	e9 fe f6 ff ff       	jmp    80106648 <alltraps>

80106f4a <vector80>:
.globl vector80
vector80:
  pushl $0
80106f4a:	6a 00                	push   $0x0
  pushl $80
80106f4c:	6a 50                	push   $0x50
  jmp alltraps
80106f4e:	e9 f5 f6 ff ff       	jmp    80106648 <alltraps>

80106f53 <vector81>:
.globl vector81
vector81:
  pushl $0
80106f53:	6a 00                	push   $0x0
  pushl $81
80106f55:	6a 51                	push   $0x51
  jmp alltraps
80106f57:	e9 ec f6 ff ff       	jmp    80106648 <alltraps>

80106f5c <vector82>:
.globl vector82
vector82:
  pushl $0
80106f5c:	6a 00                	push   $0x0
  pushl $82
80106f5e:	6a 52                	push   $0x52
  jmp alltraps
80106f60:	e9 e3 f6 ff ff       	jmp    80106648 <alltraps>

80106f65 <vector83>:
.globl vector83
vector83:
  pushl $0
80106f65:	6a 00                	push   $0x0
  pushl $83
80106f67:	6a 53                	push   $0x53
  jmp alltraps
80106f69:	e9 da f6 ff ff       	jmp    80106648 <alltraps>

80106f6e <vector84>:
.globl vector84
vector84:
  pushl $0
80106f6e:	6a 00                	push   $0x0
  pushl $84
80106f70:	6a 54                	push   $0x54
  jmp alltraps
80106f72:	e9 d1 f6 ff ff       	jmp    80106648 <alltraps>

80106f77 <vector85>:
.globl vector85
vector85:
  pushl $0
80106f77:	6a 00                	push   $0x0
  pushl $85
80106f79:	6a 55                	push   $0x55
  jmp alltraps
80106f7b:	e9 c8 f6 ff ff       	jmp    80106648 <alltraps>

80106f80 <vector86>:
.globl vector86
vector86:
  pushl $0
80106f80:	6a 00                	push   $0x0
  pushl $86
80106f82:	6a 56                	push   $0x56
  jmp alltraps
80106f84:	e9 bf f6 ff ff       	jmp    80106648 <alltraps>

80106f89 <vector87>:
.globl vector87
vector87:
  pushl $0
80106f89:	6a 00                	push   $0x0
  pushl $87
80106f8b:	6a 57                	push   $0x57
  jmp alltraps
80106f8d:	e9 b6 f6 ff ff       	jmp    80106648 <alltraps>

80106f92 <vector88>:
.globl vector88
vector88:
  pushl $0
80106f92:	6a 00                	push   $0x0
  pushl $88
80106f94:	6a 58                	push   $0x58
  jmp alltraps
80106f96:	e9 ad f6 ff ff       	jmp    80106648 <alltraps>

80106f9b <vector89>:
.globl vector89
vector89:
  pushl $0
80106f9b:	6a 00                	push   $0x0
  pushl $89
80106f9d:	6a 59                	push   $0x59
  jmp alltraps
80106f9f:	e9 a4 f6 ff ff       	jmp    80106648 <alltraps>

80106fa4 <vector90>:
.globl vector90
vector90:
  pushl $0
80106fa4:	6a 00                	push   $0x0
  pushl $90
80106fa6:	6a 5a                	push   $0x5a
  jmp alltraps
80106fa8:	e9 9b f6 ff ff       	jmp    80106648 <alltraps>

80106fad <vector91>:
.globl vector91
vector91:
  pushl $0
80106fad:	6a 00                	push   $0x0
  pushl $91
80106faf:	6a 5b                	push   $0x5b
  jmp alltraps
80106fb1:	e9 92 f6 ff ff       	jmp    80106648 <alltraps>

80106fb6 <vector92>:
.globl vector92
vector92:
  pushl $0
80106fb6:	6a 00                	push   $0x0
  pushl $92
80106fb8:	6a 5c                	push   $0x5c
  jmp alltraps
80106fba:	e9 89 f6 ff ff       	jmp    80106648 <alltraps>

80106fbf <vector93>:
.globl vector93
vector93:
  pushl $0
80106fbf:	6a 00                	push   $0x0
  pushl $93
80106fc1:	6a 5d                	push   $0x5d
  jmp alltraps
80106fc3:	e9 80 f6 ff ff       	jmp    80106648 <alltraps>

80106fc8 <vector94>:
.globl vector94
vector94:
  pushl $0
80106fc8:	6a 00                	push   $0x0
  pushl $94
80106fca:	6a 5e                	push   $0x5e
  jmp alltraps
80106fcc:	e9 77 f6 ff ff       	jmp    80106648 <alltraps>

80106fd1 <vector95>:
.globl vector95
vector95:
  pushl $0
80106fd1:	6a 00                	push   $0x0
  pushl $95
80106fd3:	6a 5f                	push   $0x5f
  jmp alltraps
80106fd5:	e9 6e f6 ff ff       	jmp    80106648 <alltraps>

80106fda <vector96>:
.globl vector96
vector96:
  pushl $0
80106fda:	6a 00                	push   $0x0
  pushl $96
80106fdc:	6a 60                	push   $0x60
  jmp alltraps
80106fde:	e9 65 f6 ff ff       	jmp    80106648 <alltraps>

80106fe3 <vector97>:
.globl vector97
vector97:
  pushl $0
80106fe3:	6a 00                	push   $0x0
  pushl $97
80106fe5:	6a 61                	push   $0x61
  jmp alltraps
80106fe7:	e9 5c f6 ff ff       	jmp    80106648 <alltraps>

80106fec <vector98>:
.globl vector98
vector98:
  pushl $0
80106fec:	6a 00                	push   $0x0
  pushl $98
80106fee:	6a 62                	push   $0x62
  jmp alltraps
80106ff0:	e9 53 f6 ff ff       	jmp    80106648 <alltraps>

80106ff5 <vector99>:
.globl vector99
vector99:
  pushl $0
80106ff5:	6a 00                	push   $0x0
  pushl $99
80106ff7:	6a 63                	push   $0x63
  jmp alltraps
80106ff9:	e9 4a f6 ff ff       	jmp    80106648 <alltraps>

80106ffe <vector100>:
.globl vector100
vector100:
  pushl $0
80106ffe:	6a 00                	push   $0x0
  pushl $100
80107000:	6a 64                	push   $0x64
  jmp alltraps
80107002:	e9 41 f6 ff ff       	jmp    80106648 <alltraps>

80107007 <vector101>:
.globl vector101
vector101:
  pushl $0
80107007:	6a 00                	push   $0x0
  pushl $101
80107009:	6a 65                	push   $0x65
  jmp alltraps
8010700b:	e9 38 f6 ff ff       	jmp    80106648 <alltraps>

80107010 <vector102>:
.globl vector102
vector102:
  pushl $0
80107010:	6a 00                	push   $0x0
  pushl $102
80107012:	6a 66                	push   $0x66
  jmp alltraps
80107014:	e9 2f f6 ff ff       	jmp    80106648 <alltraps>

80107019 <vector103>:
.globl vector103
vector103:
  pushl $0
80107019:	6a 00                	push   $0x0
  pushl $103
8010701b:	6a 67                	push   $0x67
  jmp alltraps
8010701d:	e9 26 f6 ff ff       	jmp    80106648 <alltraps>

80107022 <vector104>:
.globl vector104
vector104:
  pushl $0
80107022:	6a 00                	push   $0x0
  pushl $104
80107024:	6a 68                	push   $0x68
  jmp alltraps
80107026:	e9 1d f6 ff ff       	jmp    80106648 <alltraps>

8010702b <vector105>:
.globl vector105
vector105:
  pushl $0
8010702b:	6a 00                	push   $0x0
  pushl $105
8010702d:	6a 69                	push   $0x69
  jmp alltraps
8010702f:	e9 14 f6 ff ff       	jmp    80106648 <alltraps>

80107034 <vector106>:
.globl vector106
vector106:
  pushl $0
80107034:	6a 00                	push   $0x0
  pushl $106
80107036:	6a 6a                	push   $0x6a
  jmp alltraps
80107038:	e9 0b f6 ff ff       	jmp    80106648 <alltraps>

8010703d <vector107>:
.globl vector107
vector107:
  pushl $0
8010703d:	6a 00                	push   $0x0
  pushl $107
8010703f:	6a 6b                	push   $0x6b
  jmp alltraps
80107041:	e9 02 f6 ff ff       	jmp    80106648 <alltraps>

80107046 <vector108>:
.globl vector108
vector108:
  pushl $0
80107046:	6a 00                	push   $0x0
  pushl $108
80107048:	6a 6c                	push   $0x6c
  jmp alltraps
8010704a:	e9 f9 f5 ff ff       	jmp    80106648 <alltraps>

8010704f <vector109>:
.globl vector109
vector109:
  pushl $0
8010704f:	6a 00                	push   $0x0
  pushl $109
80107051:	6a 6d                	push   $0x6d
  jmp alltraps
80107053:	e9 f0 f5 ff ff       	jmp    80106648 <alltraps>

80107058 <vector110>:
.globl vector110
vector110:
  pushl $0
80107058:	6a 00                	push   $0x0
  pushl $110
8010705a:	6a 6e                	push   $0x6e
  jmp alltraps
8010705c:	e9 e7 f5 ff ff       	jmp    80106648 <alltraps>

80107061 <vector111>:
.globl vector111
vector111:
  pushl $0
80107061:	6a 00                	push   $0x0
  pushl $111
80107063:	6a 6f                	push   $0x6f
  jmp alltraps
80107065:	e9 de f5 ff ff       	jmp    80106648 <alltraps>

8010706a <vector112>:
.globl vector112
vector112:
  pushl $0
8010706a:	6a 00                	push   $0x0
  pushl $112
8010706c:	6a 70                	push   $0x70
  jmp alltraps
8010706e:	e9 d5 f5 ff ff       	jmp    80106648 <alltraps>

80107073 <vector113>:
.globl vector113
vector113:
  pushl $0
80107073:	6a 00                	push   $0x0
  pushl $113
80107075:	6a 71                	push   $0x71
  jmp alltraps
80107077:	e9 cc f5 ff ff       	jmp    80106648 <alltraps>

8010707c <vector114>:
.globl vector114
vector114:
  pushl $0
8010707c:	6a 00                	push   $0x0
  pushl $114
8010707e:	6a 72                	push   $0x72
  jmp alltraps
80107080:	e9 c3 f5 ff ff       	jmp    80106648 <alltraps>

80107085 <vector115>:
.globl vector115
vector115:
  pushl $0
80107085:	6a 00                	push   $0x0
  pushl $115
80107087:	6a 73                	push   $0x73
  jmp alltraps
80107089:	e9 ba f5 ff ff       	jmp    80106648 <alltraps>

8010708e <vector116>:
.globl vector116
vector116:
  pushl $0
8010708e:	6a 00                	push   $0x0
  pushl $116
80107090:	6a 74                	push   $0x74
  jmp alltraps
80107092:	e9 b1 f5 ff ff       	jmp    80106648 <alltraps>

80107097 <vector117>:
.globl vector117
vector117:
  pushl $0
80107097:	6a 00                	push   $0x0
  pushl $117
80107099:	6a 75                	push   $0x75
  jmp alltraps
8010709b:	e9 a8 f5 ff ff       	jmp    80106648 <alltraps>

801070a0 <vector118>:
.globl vector118
vector118:
  pushl $0
801070a0:	6a 00                	push   $0x0
  pushl $118
801070a2:	6a 76                	push   $0x76
  jmp alltraps
801070a4:	e9 9f f5 ff ff       	jmp    80106648 <alltraps>

801070a9 <vector119>:
.globl vector119
vector119:
  pushl $0
801070a9:	6a 00                	push   $0x0
  pushl $119
801070ab:	6a 77                	push   $0x77
  jmp alltraps
801070ad:	e9 96 f5 ff ff       	jmp    80106648 <alltraps>

801070b2 <vector120>:
.globl vector120
vector120:
  pushl $0
801070b2:	6a 00                	push   $0x0
  pushl $120
801070b4:	6a 78                	push   $0x78
  jmp alltraps
801070b6:	e9 8d f5 ff ff       	jmp    80106648 <alltraps>

801070bb <vector121>:
.globl vector121
vector121:
  pushl $0
801070bb:	6a 00                	push   $0x0
  pushl $121
801070bd:	6a 79                	push   $0x79
  jmp alltraps
801070bf:	e9 84 f5 ff ff       	jmp    80106648 <alltraps>

801070c4 <vector122>:
.globl vector122
vector122:
  pushl $0
801070c4:	6a 00                	push   $0x0
  pushl $122
801070c6:	6a 7a                	push   $0x7a
  jmp alltraps
801070c8:	e9 7b f5 ff ff       	jmp    80106648 <alltraps>

801070cd <vector123>:
.globl vector123
vector123:
  pushl $0
801070cd:	6a 00                	push   $0x0
  pushl $123
801070cf:	6a 7b                	push   $0x7b
  jmp alltraps
801070d1:	e9 72 f5 ff ff       	jmp    80106648 <alltraps>

801070d6 <vector124>:
.globl vector124
vector124:
  pushl $0
801070d6:	6a 00                	push   $0x0
  pushl $124
801070d8:	6a 7c                	push   $0x7c
  jmp alltraps
801070da:	e9 69 f5 ff ff       	jmp    80106648 <alltraps>

801070df <vector125>:
.globl vector125
vector125:
  pushl $0
801070df:	6a 00                	push   $0x0
  pushl $125
801070e1:	6a 7d                	push   $0x7d
  jmp alltraps
801070e3:	e9 60 f5 ff ff       	jmp    80106648 <alltraps>

801070e8 <vector126>:
.globl vector126
vector126:
  pushl $0
801070e8:	6a 00                	push   $0x0
  pushl $126
801070ea:	6a 7e                	push   $0x7e
  jmp alltraps
801070ec:	e9 57 f5 ff ff       	jmp    80106648 <alltraps>

801070f1 <vector127>:
.globl vector127
vector127:
  pushl $0
801070f1:	6a 00                	push   $0x0
  pushl $127
801070f3:	6a 7f                	push   $0x7f
  jmp alltraps
801070f5:	e9 4e f5 ff ff       	jmp    80106648 <alltraps>

801070fa <vector128>:
.globl vector128
vector128:
  pushl $0
801070fa:	6a 00                	push   $0x0
  pushl $128
801070fc:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107101:	e9 42 f5 ff ff       	jmp    80106648 <alltraps>

80107106 <vector129>:
.globl vector129
vector129:
  pushl $0
80107106:	6a 00                	push   $0x0
  pushl $129
80107108:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010710d:	e9 36 f5 ff ff       	jmp    80106648 <alltraps>

80107112 <vector130>:
.globl vector130
vector130:
  pushl $0
80107112:	6a 00                	push   $0x0
  pushl $130
80107114:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107119:	e9 2a f5 ff ff       	jmp    80106648 <alltraps>

8010711e <vector131>:
.globl vector131
vector131:
  pushl $0
8010711e:	6a 00                	push   $0x0
  pushl $131
80107120:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107125:	e9 1e f5 ff ff       	jmp    80106648 <alltraps>

8010712a <vector132>:
.globl vector132
vector132:
  pushl $0
8010712a:	6a 00                	push   $0x0
  pushl $132
8010712c:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107131:	e9 12 f5 ff ff       	jmp    80106648 <alltraps>

80107136 <vector133>:
.globl vector133
vector133:
  pushl $0
80107136:	6a 00                	push   $0x0
  pushl $133
80107138:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010713d:	e9 06 f5 ff ff       	jmp    80106648 <alltraps>

80107142 <vector134>:
.globl vector134
vector134:
  pushl $0
80107142:	6a 00                	push   $0x0
  pushl $134
80107144:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107149:	e9 fa f4 ff ff       	jmp    80106648 <alltraps>

8010714e <vector135>:
.globl vector135
vector135:
  pushl $0
8010714e:	6a 00                	push   $0x0
  pushl $135
80107150:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107155:	e9 ee f4 ff ff       	jmp    80106648 <alltraps>

8010715a <vector136>:
.globl vector136
vector136:
  pushl $0
8010715a:	6a 00                	push   $0x0
  pushl $136
8010715c:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107161:	e9 e2 f4 ff ff       	jmp    80106648 <alltraps>

80107166 <vector137>:
.globl vector137
vector137:
  pushl $0
80107166:	6a 00                	push   $0x0
  pushl $137
80107168:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010716d:	e9 d6 f4 ff ff       	jmp    80106648 <alltraps>

80107172 <vector138>:
.globl vector138
vector138:
  pushl $0
80107172:	6a 00                	push   $0x0
  pushl $138
80107174:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107179:	e9 ca f4 ff ff       	jmp    80106648 <alltraps>

8010717e <vector139>:
.globl vector139
vector139:
  pushl $0
8010717e:	6a 00                	push   $0x0
  pushl $139
80107180:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107185:	e9 be f4 ff ff       	jmp    80106648 <alltraps>

8010718a <vector140>:
.globl vector140
vector140:
  pushl $0
8010718a:	6a 00                	push   $0x0
  pushl $140
8010718c:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107191:	e9 b2 f4 ff ff       	jmp    80106648 <alltraps>

80107196 <vector141>:
.globl vector141
vector141:
  pushl $0
80107196:	6a 00                	push   $0x0
  pushl $141
80107198:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010719d:	e9 a6 f4 ff ff       	jmp    80106648 <alltraps>

801071a2 <vector142>:
.globl vector142
vector142:
  pushl $0
801071a2:	6a 00                	push   $0x0
  pushl $142
801071a4:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801071a9:	e9 9a f4 ff ff       	jmp    80106648 <alltraps>

801071ae <vector143>:
.globl vector143
vector143:
  pushl $0
801071ae:	6a 00                	push   $0x0
  pushl $143
801071b0:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801071b5:	e9 8e f4 ff ff       	jmp    80106648 <alltraps>

801071ba <vector144>:
.globl vector144
vector144:
  pushl $0
801071ba:	6a 00                	push   $0x0
  pushl $144
801071bc:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801071c1:	e9 82 f4 ff ff       	jmp    80106648 <alltraps>

801071c6 <vector145>:
.globl vector145
vector145:
  pushl $0
801071c6:	6a 00                	push   $0x0
  pushl $145
801071c8:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801071cd:	e9 76 f4 ff ff       	jmp    80106648 <alltraps>

801071d2 <vector146>:
.globl vector146
vector146:
  pushl $0
801071d2:	6a 00                	push   $0x0
  pushl $146
801071d4:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801071d9:	e9 6a f4 ff ff       	jmp    80106648 <alltraps>

801071de <vector147>:
.globl vector147
vector147:
  pushl $0
801071de:	6a 00                	push   $0x0
  pushl $147
801071e0:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801071e5:	e9 5e f4 ff ff       	jmp    80106648 <alltraps>

801071ea <vector148>:
.globl vector148
vector148:
  pushl $0
801071ea:	6a 00                	push   $0x0
  pushl $148
801071ec:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801071f1:	e9 52 f4 ff ff       	jmp    80106648 <alltraps>

801071f6 <vector149>:
.globl vector149
vector149:
  pushl $0
801071f6:	6a 00                	push   $0x0
  pushl $149
801071f8:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801071fd:	e9 46 f4 ff ff       	jmp    80106648 <alltraps>

80107202 <vector150>:
.globl vector150
vector150:
  pushl $0
80107202:	6a 00                	push   $0x0
  pushl $150
80107204:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107209:	e9 3a f4 ff ff       	jmp    80106648 <alltraps>

8010720e <vector151>:
.globl vector151
vector151:
  pushl $0
8010720e:	6a 00                	push   $0x0
  pushl $151
80107210:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107215:	e9 2e f4 ff ff       	jmp    80106648 <alltraps>

8010721a <vector152>:
.globl vector152
vector152:
  pushl $0
8010721a:	6a 00                	push   $0x0
  pushl $152
8010721c:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107221:	e9 22 f4 ff ff       	jmp    80106648 <alltraps>

80107226 <vector153>:
.globl vector153
vector153:
  pushl $0
80107226:	6a 00                	push   $0x0
  pushl $153
80107228:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010722d:	e9 16 f4 ff ff       	jmp    80106648 <alltraps>

80107232 <vector154>:
.globl vector154
vector154:
  pushl $0
80107232:	6a 00                	push   $0x0
  pushl $154
80107234:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107239:	e9 0a f4 ff ff       	jmp    80106648 <alltraps>

8010723e <vector155>:
.globl vector155
vector155:
  pushl $0
8010723e:	6a 00                	push   $0x0
  pushl $155
80107240:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107245:	e9 fe f3 ff ff       	jmp    80106648 <alltraps>

8010724a <vector156>:
.globl vector156
vector156:
  pushl $0
8010724a:	6a 00                	push   $0x0
  pushl $156
8010724c:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107251:	e9 f2 f3 ff ff       	jmp    80106648 <alltraps>

80107256 <vector157>:
.globl vector157
vector157:
  pushl $0
80107256:	6a 00                	push   $0x0
  pushl $157
80107258:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010725d:	e9 e6 f3 ff ff       	jmp    80106648 <alltraps>

80107262 <vector158>:
.globl vector158
vector158:
  pushl $0
80107262:	6a 00                	push   $0x0
  pushl $158
80107264:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107269:	e9 da f3 ff ff       	jmp    80106648 <alltraps>

8010726e <vector159>:
.globl vector159
vector159:
  pushl $0
8010726e:	6a 00                	push   $0x0
  pushl $159
80107270:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107275:	e9 ce f3 ff ff       	jmp    80106648 <alltraps>

8010727a <vector160>:
.globl vector160
vector160:
  pushl $0
8010727a:	6a 00                	push   $0x0
  pushl $160
8010727c:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107281:	e9 c2 f3 ff ff       	jmp    80106648 <alltraps>

80107286 <vector161>:
.globl vector161
vector161:
  pushl $0
80107286:	6a 00                	push   $0x0
  pushl $161
80107288:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010728d:	e9 b6 f3 ff ff       	jmp    80106648 <alltraps>

80107292 <vector162>:
.globl vector162
vector162:
  pushl $0
80107292:	6a 00                	push   $0x0
  pushl $162
80107294:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107299:	e9 aa f3 ff ff       	jmp    80106648 <alltraps>

8010729e <vector163>:
.globl vector163
vector163:
  pushl $0
8010729e:	6a 00                	push   $0x0
  pushl $163
801072a0:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801072a5:	e9 9e f3 ff ff       	jmp    80106648 <alltraps>

801072aa <vector164>:
.globl vector164
vector164:
  pushl $0
801072aa:	6a 00                	push   $0x0
  pushl $164
801072ac:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801072b1:	e9 92 f3 ff ff       	jmp    80106648 <alltraps>

801072b6 <vector165>:
.globl vector165
vector165:
  pushl $0
801072b6:	6a 00                	push   $0x0
  pushl $165
801072b8:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801072bd:	e9 86 f3 ff ff       	jmp    80106648 <alltraps>

801072c2 <vector166>:
.globl vector166
vector166:
  pushl $0
801072c2:	6a 00                	push   $0x0
  pushl $166
801072c4:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801072c9:	e9 7a f3 ff ff       	jmp    80106648 <alltraps>

801072ce <vector167>:
.globl vector167
vector167:
  pushl $0
801072ce:	6a 00                	push   $0x0
  pushl $167
801072d0:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801072d5:	e9 6e f3 ff ff       	jmp    80106648 <alltraps>

801072da <vector168>:
.globl vector168
vector168:
  pushl $0
801072da:	6a 00                	push   $0x0
  pushl $168
801072dc:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801072e1:	e9 62 f3 ff ff       	jmp    80106648 <alltraps>

801072e6 <vector169>:
.globl vector169
vector169:
  pushl $0
801072e6:	6a 00                	push   $0x0
  pushl $169
801072e8:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801072ed:	e9 56 f3 ff ff       	jmp    80106648 <alltraps>

801072f2 <vector170>:
.globl vector170
vector170:
  pushl $0
801072f2:	6a 00                	push   $0x0
  pushl $170
801072f4:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801072f9:	e9 4a f3 ff ff       	jmp    80106648 <alltraps>

801072fe <vector171>:
.globl vector171
vector171:
  pushl $0
801072fe:	6a 00                	push   $0x0
  pushl $171
80107300:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107305:	e9 3e f3 ff ff       	jmp    80106648 <alltraps>

8010730a <vector172>:
.globl vector172
vector172:
  pushl $0
8010730a:	6a 00                	push   $0x0
  pushl $172
8010730c:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107311:	e9 32 f3 ff ff       	jmp    80106648 <alltraps>

80107316 <vector173>:
.globl vector173
vector173:
  pushl $0
80107316:	6a 00                	push   $0x0
  pushl $173
80107318:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
8010731d:	e9 26 f3 ff ff       	jmp    80106648 <alltraps>

80107322 <vector174>:
.globl vector174
vector174:
  pushl $0
80107322:	6a 00                	push   $0x0
  pushl $174
80107324:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107329:	e9 1a f3 ff ff       	jmp    80106648 <alltraps>

8010732e <vector175>:
.globl vector175
vector175:
  pushl $0
8010732e:	6a 00                	push   $0x0
  pushl $175
80107330:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107335:	e9 0e f3 ff ff       	jmp    80106648 <alltraps>

8010733a <vector176>:
.globl vector176
vector176:
  pushl $0
8010733a:	6a 00                	push   $0x0
  pushl $176
8010733c:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107341:	e9 02 f3 ff ff       	jmp    80106648 <alltraps>

80107346 <vector177>:
.globl vector177
vector177:
  pushl $0
80107346:	6a 00                	push   $0x0
  pushl $177
80107348:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
8010734d:	e9 f6 f2 ff ff       	jmp    80106648 <alltraps>

80107352 <vector178>:
.globl vector178
vector178:
  pushl $0
80107352:	6a 00                	push   $0x0
  pushl $178
80107354:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107359:	e9 ea f2 ff ff       	jmp    80106648 <alltraps>

8010735e <vector179>:
.globl vector179
vector179:
  pushl $0
8010735e:	6a 00                	push   $0x0
  pushl $179
80107360:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107365:	e9 de f2 ff ff       	jmp    80106648 <alltraps>

8010736a <vector180>:
.globl vector180
vector180:
  pushl $0
8010736a:	6a 00                	push   $0x0
  pushl $180
8010736c:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107371:	e9 d2 f2 ff ff       	jmp    80106648 <alltraps>

80107376 <vector181>:
.globl vector181
vector181:
  pushl $0
80107376:	6a 00                	push   $0x0
  pushl $181
80107378:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010737d:	e9 c6 f2 ff ff       	jmp    80106648 <alltraps>

80107382 <vector182>:
.globl vector182
vector182:
  pushl $0
80107382:	6a 00                	push   $0x0
  pushl $182
80107384:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107389:	e9 ba f2 ff ff       	jmp    80106648 <alltraps>

8010738e <vector183>:
.globl vector183
vector183:
  pushl $0
8010738e:	6a 00                	push   $0x0
  pushl $183
80107390:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107395:	e9 ae f2 ff ff       	jmp    80106648 <alltraps>

8010739a <vector184>:
.globl vector184
vector184:
  pushl $0
8010739a:	6a 00                	push   $0x0
  pushl $184
8010739c:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801073a1:	e9 a2 f2 ff ff       	jmp    80106648 <alltraps>

801073a6 <vector185>:
.globl vector185
vector185:
  pushl $0
801073a6:	6a 00                	push   $0x0
  pushl $185
801073a8:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801073ad:	e9 96 f2 ff ff       	jmp    80106648 <alltraps>

801073b2 <vector186>:
.globl vector186
vector186:
  pushl $0
801073b2:	6a 00                	push   $0x0
  pushl $186
801073b4:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801073b9:	e9 8a f2 ff ff       	jmp    80106648 <alltraps>

801073be <vector187>:
.globl vector187
vector187:
  pushl $0
801073be:	6a 00                	push   $0x0
  pushl $187
801073c0:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801073c5:	e9 7e f2 ff ff       	jmp    80106648 <alltraps>

801073ca <vector188>:
.globl vector188
vector188:
  pushl $0
801073ca:	6a 00                	push   $0x0
  pushl $188
801073cc:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801073d1:	e9 72 f2 ff ff       	jmp    80106648 <alltraps>

801073d6 <vector189>:
.globl vector189
vector189:
  pushl $0
801073d6:	6a 00                	push   $0x0
  pushl $189
801073d8:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801073dd:	e9 66 f2 ff ff       	jmp    80106648 <alltraps>

801073e2 <vector190>:
.globl vector190
vector190:
  pushl $0
801073e2:	6a 00                	push   $0x0
  pushl $190
801073e4:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801073e9:	e9 5a f2 ff ff       	jmp    80106648 <alltraps>

801073ee <vector191>:
.globl vector191
vector191:
  pushl $0
801073ee:	6a 00                	push   $0x0
  pushl $191
801073f0:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801073f5:	e9 4e f2 ff ff       	jmp    80106648 <alltraps>

801073fa <vector192>:
.globl vector192
vector192:
  pushl $0
801073fa:	6a 00                	push   $0x0
  pushl $192
801073fc:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107401:	e9 42 f2 ff ff       	jmp    80106648 <alltraps>

80107406 <vector193>:
.globl vector193
vector193:
  pushl $0
80107406:	6a 00                	push   $0x0
  pushl $193
80107408:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010740d:	e9 36 f2 ff ff       	jmp    80106648 <alltraps>

80107412 <vector194>:
.globl vector194
vector194:
  pushl $0
80107412:	6a 00                	push   $0x0
  pushl $194
80107414:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107419:	e9 2a f2 ff ff       	jmp    80106648 <alltraps>

8010741e <vector195>:
.globl vector195
vector195:
  pushl $0
8010741e:	6a 00                	push   $0x0
  pushl $195
80107420:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107425:	e9 1e f2 ff ff       	jmp    80106648 <alltraps>

8010742a <vector196>:
.globl vector196
vector196:
  pushl $0
8010742a:	6a 00                	push   $0x0
  pushl $196
8010742c:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107431:	e9 12 f2 ff ff       	jmp    80106648 <alltraps>

80107436 <vector197>:
.globl vector197
vector197:
  pushl $0
80107436:	6a 00                	push   $0x0
  pushl $197
80107438:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010743d:	e9 06 f2 ff ff       	jmp    80106648 <alltraps>

80107442 <vector198>:
.globl vector198
vector198:
  pushl $0
80107442:	6a 00                	push   $0x0
  pushl $198
80107444:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107449:	e9 fa f1 ff ff       	jmp    80106648 <alltraps>

8010744e <vector199>:
.globl vector199
vector199:
  pushl $0
8010744e:	6a 00                	push   $0x0
  pushl $199
80107450:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107455:	e9 ee f1 ff ff       	jmp    80106648 <alltraps>

8010745a <vector200>:
.globl vector200
vector200:
  pushl $0
8010745a:	6a 00                	push   $0x0
  pushl $200
8010745c:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107461:	e9 e2 f1 ff ff       	jmp    80106648 <alltraps>

80107466 <vector201>:
.globl vector201
vector201:
  pushl $0
80107466:	6a 00                	push   $0x0
  pushl $201
80107468:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
8010746d:	e9 d6 f1 ff ff       	jmp    80106648 <alltraps>

80107472 <vector202>:
.globl vector202
vector202:
  pushl $0
80107472:	6a 00                	push   $0x0
  pushl $202
80107474:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107479:	e9 ca f1 ff ff       	jmp    80106648 <alltraps>

8010747e <vector203>:
.globl vector203
vector203:
  pushl $0
8010747e:	6a 00                	push   $0x0
  pushl $203
80107480:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107485:	e9 be f1 ff ff       	jmp    80106648 <alltraps>

8010748a <vector204>:
.globl vector204
vector204:
  pushl $0
8010748a:	6a 00                	push   $0x0
  pushl $204
8010748c:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107491:	e9 b2 f1 ff ff       	jmp    80106648 <alltraps>

80107496 <vector205>:
.globl vector205
vector205:
  pushl $0
80107496:	6a 00                	push   $0x0
  pushl $205
80107498:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010749d:	e9 a6 f1 ff ff       	jmp    80106648 <alltraps>

801074a2 <vector206>:
.globl vector206
vector206:
  pushl $0
801074a2:	6a 00                	push   $0x0
  pushl $206
801074a4:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801074a9:	e9 9a f1 ff ff       	jmp    80106648 <alltraps>

801074ae <vector207>:
.globl vector207
vector207:
  pushl $0
801074ae:	6a 00                	push   $0x0
  pushl $207
801074b0:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801074b5:	e9 8e f1 ff ff       	jmp    80106648 <alltraps>

801074ba <vector208>:
.globl vector208
vector208:
  pushl $0
801074ba:	6a 00                	push   $0x0
  pushl $208
801074bc:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801074c1:	e9 82 f1 ff ff       	jmp    80106648 <alltraps>

801074c6 <vector209>:
.globl vector209
vector209:
  pushl $0
801074c6:	6a 00                	push   $0x0
  pushl $209
801074c8:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801074cd:	e9 76 f1 ff ff       	jmp    80106648 <alltraps>

801074d2 <vector210>:
.globl vector210
vector210:
  pushl $0
801074d2:	6a 00                	push   $0x0
  pushl $210
801074d4:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801074d9:	e9 6a f1 ff ff       	jmp    80106648 <alltraps>

801074de <vector211>:
.globl vector211
vector211:
  pushl $0
801074de:	6a 00                	push   $0x0
  pushl $211
801074e0:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801074e5:	e9 5e f1 ff ff       	jmp    80106648 <alltraps>

801074ea <vector212>:
.globl vector212
vector212:
  pushl $0
801074ea:	6a 00                	push   $0x0
  pushl $212
801074ec:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801074f1:	e9 52 f1 ff ff       	jmp    80106648 <alltraps>

801074f6 <vector213>:
.globl vector213
vector213:
  pushl $0
801074f6:	6a 00                	push   $0x0
  pushl $213
801074f8:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801074fd:	e9 46 f1 ff ff       	jmp    80106648 <alltraps>

80107502 <vector214>:
.globl vector214
vector214:
  pushl $0
80107502:	6a 00                	push   $0x0
  pushl $214
80107504:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107509:	e9 3a f1 ff ff       	jmp    80106648 <alltraps>

8010750e <vector215>:
.globl vector215
vector215:
  pushl $0
8010750e:	6a 00                	push   $0x0
  pushl $215
80107510:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107515:	e9 2e f1 ff ff       	jmp    80106648 <alltraps>

8010751a <vector216>:
.globl vector216
vector216:
  pushl $0
8010751a:	6a 00                	push   $0x0
  pushl $216
8010751c:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107521:	e9 22 f1 ff ff       	jmp    80106648 <alltraps>

80107526 <vector217>:
.globl vector217
vector217:
  pushl $0
80107526:	6a 00                	push   $0x0
  pushl $217
80107528:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
8010752d:	e9 16 f1 ff ff       	jmp    80106648 <alltraps>

80107532 <vector218>:
.globl vector218
vector218:
  pushl $0
80107532:	6a 00                	push   $0x0
  pushl $218
80107534:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107539:	e9 0a f1 ff ff       	jmp    80106648 <alltraps>

8010753e <vector219>:
.globl vector219
vector219:
  pushl $0
8010753e:	6a 00                	push   $0x0
  pushl $219
80107540:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107545:	e9 fe f0 ff ff       	jmp    80106648 <alltraps>

8010754a <vector220>:
.globl vector220
vector220:
  pushl $0
8010754a:	6a 00                	push   $0x0
  pushl $220
8010754c:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107551:	e9 f2 f0 ff ff       	jmp    80106648 <alltraps>

80107556 <vector221>:
.globl vector221
vector221:
  pushl $0
80107556:	6a 00                	push   $0x0
  pushl $221
80107558:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
8010755d:	e9 e6 f0 ff ff       	jmp    80106648 <alltraps>

80107562 <vector222>:
.globl vector222
vector222:
  pushl $0
80107562:	6a 00                	push   $0x0
  pushl $222
80107564:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107569:	e9 da f0 ff ff       	jmp    80106648 <alltraps>

8010756e <vector223>:
.globl vector223
vector223:
  pushl $0
8010756e:	6a 00                	push   $0x0
  pushl $223
80107570:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107575:	e9 ce f0 ff ff       	jmp    80106648 <alltraps>

8010757a <vector224>:
.globl vector224
vector224:
  pushl $0
8010757a:	6a 00                	push   $0x0
  pushl $224
8010757c:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107581:	e9 c2 f0 ff ff       	jmp    80106648 <alltraps>

80107586 <vector225>:
.globl vector225
vector225:
  pushl $0
80107586:	6a 00                	push   $0x0
  pushl $225
80107588:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
8010758d:	e9 b6 f0 ff ff       	jmp    80106648 <alltraps>

80107592 <vector226>:
.globl vector226
vector226:
  pushl $0
80107592:	6a 00                	push   $0x0
  pushl $226
80107594:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107599:	e9 aa f0 ff ff       	jmp    80106648 <alltraps>

8010759e <vector227>:
.globl vector227
vector227:
  pushl $0
8010759e:	6a 00                	push   $0x0
  pushl $227
801075a0:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801075a5:	e9 9e f0 ff ff       	jmp    80106648 <alltraps>

801075aa <vector228>:
.globl vector228
vector228:
  pushl $0
801075aa:	6a 00                	push   $0x0
  pushl $228
801075ac:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801075b1:	e9 92 f0 ff ff       	jmp    80106648 <alltraps>

801075b6 <vector229>:
.globl vector229
vector229:
  pushl $0
801075b6:	6a 00                	push   $0x0
  pushl $229
801075b8:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801075bd:	e9 86 f0 ff ff       	jmp    80106648 <alltraps>

801075c2 <vector230>:
.globl vector230
vector230:
  pushl $0
801075c2:	6a 00                	push   $0x0
  pushl $230
801075c4:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801075c9:	e9 7a f0 ff ff       	jmp    80106648 <alltraps>

801075ce <vector231>:
.globl vector231
vector231:
  pushl $0
801075ce:	6a 00                	push   $0x0
  pushl $231
801075d0:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801075d5:	e9 6e f0 ff ff       	jmp    80106648 <alltraps>

801075da <vector232>:
.globl vector232
vector232:
  pushl $0
801075da:	6a 00                	push   $0x0
  pushl $232
801075dc:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801075e1:	e9 62 f0 ff ff       	jmp    80106648 <alltraps>

801075e6 <vector233>:
.globl vector233
vector233:
  pushl $0
801075e6:	6a 00                	push   $0x0
  pushl $233
801075e8:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801075ed:	e9 56 f0 ff ff       	jmp    80106648 <alltraps>

801075f2 <vector234>:
.globl vector234
vector234:
  pushl $0
801075f2:	6a 00                	push   $0x0
  pushl $234
801075f4:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801075f9:	e9 4a f0 ff ff       	jmp    80106648 <alltraps>

801075fe <vector235>:
.globl vector235
vector235:
  pushl $0
801075fe:	6a 00                	push   $0x0
  pushl $235
80107600:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107605:	e9 3e f0 ff ff       	jmp    80106648 <alltraps>

8010760a <vector236>:
.globl vector236
vector236:
  pushl $0
8010760a:	6a 00                	push   $0x0
  pushl $236
8010760c:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107611:	e9 32 f0 ff ff       	jmp    80106648 <alltraps>

80107616 <vector237>:
.globl vector237
vector237:
  pushl $0
80107616:	6a 00                	push   $0x0
  pushl $237
80107618:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010761d:	e9 26 f0 ff ff       	jmp    80106648 <alltraps>

80107622 <vector238>:
.globl vector238
vector238:
  pushl $0
80107622:	6a 00                	push   $0x0
  pushl $238
80107624:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107629:	e9 1a f0 ff ff       	jmp    80106648 <alltraps>

8010762e <vector239>:
.globl vector239
vector239:
  pushl $0
8010762e:	6a 00                	push   $0x0
  pushl $239
80107630:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107635:	e9 0e f0 ff ff       	jmp    80106648 <alltraps>

8010763a <vector240>:
.globl vector240
vector240:
  pushl $0
8010763a:	6a 00                	push   $0x0
  pushl $240
8010763c:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107641:	e9 02 f0 ff ff       	jmp    80106648 <alltraps>

80107646 <vector241>:
.globl vector241
vector241:
  pushl $0
80107646:	6a 00                	push   $0x0
  pushl $241
80107648:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
8010764d:	e9 f6 ef ff ff       	jmp    80106648 <alltraps>

80107652 <vector242>:
.globl vector242
vector242:
  pushl $0
80107652:	6a 00                	push   $0x0
  pushl $242
80107654:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107659:	e9 ea ef ff ff       	jmp    80106648 <alltraps>

8010765e <vector243>:
.globl vector243
vector243:
  pushl $0
8010765e:	6a 00                	push   $0x0
  pushl $243
80107660:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107665:	e9 de ef ff ff       	jmp    80106648 <alltraps>

8010766a <vector244>:
.globl vector244
vector244:
  pushl $0
8010766a:	6a 00                	push   $0x0
  pushl $244
8010766c:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107671:	e9 d2 ef ff ff       	jmp    80106648 <alltraps>

80107676 <vector245>:
.globl vector245
vector245:
  pushl $0
80107676:	6a 00                	push   $0x0
  pushl $245
80107678:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010767d:	e9 c6 ef ff ff       	jmp    80106648 <alltraps>

80107682 <vector246>:
.globl vector246
vector246:
  pushl $0
80107682:	6a 00                	push   $0x0
  pushl $246
80107684:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107689:	e9 ba ef ff ff       	jmp    80106648 <alltraps>

8010768e <vector247>:
.globl vector247
vector247:
  pushl $0
8010768e:	6a 00                	push   $0x0
  pushl $247
80107690:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107695:	e9 ae ef ff ff       	jmp    80106648 <alltraps>

8010769a <vector248>:
.globl vector248
vector248:
  pushl $0
8010769a:	6a 00                	push   $0x0
  pushl $248
8010769c:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801076a1:	e9 a2 ef ff ff       	jmp    80106648 <alltraps>

801076a6 <vector249>:
.globl vector249
vector249:
  pushl $0
801076a6:	6a 00                	push   $0x0
  pushl $249
801076a8:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801076ad:	e9 96 ef ff ff       	jmp    80106648 <alltraps>

801076b2 <vector250>:
.globl vector250
vector250:
  pushl $0
801076b2:	6a 00                	push   $0x0
  pushl $250
801076b4:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801076b9:	e9 8a ef ff ff       	jmp    80106648 <alltraps>

801076be <vector251>:
.globl vector251
vector251:
  pushl $0
801076be:	6a 00                	push   $0x0
  pushl $251
801076c0:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801076c5:	e9 7e ef ff ff       	jmp    80106648 <alltraps>

801076ca <vector252>:
.globl vector252
vector252:
  pushl $0
801076ca:	6a 00                	push   $0x0
  pushl $252
801076cc:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801076d1:	e9 72 ef ff ff       	jmp    80106648 <alltraps>

801076d6 <vector253>:
.globl vector253
vector253:
  pushl $0
801076d6:	6a 00                	push   $0x0
  pushl $253
801076d8:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801076dd:	e9 66 ef ff ff       	jmp    80106648 <alltraps>

801076e2 <vector254>:
.globl vector254
vector254:
  pushl $0
801076e2:	6a 00                	push   $0x0
  pushl $254
801076e4:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801076e9:	e9 5a ef ff ff       	jmp    80106648 <alltraps>

801076ee <vector255>:
.globl vector255
vector255:
  pushl $0
801076ee:	6a 00                	push   $0x0
  pushl $255
801076f0:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801076f5:	e9 4e ef ff ff       	jmp    80106648 <alltraps>
	...

801076fc <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
801076fc:	55                   	push   %ebp
801076fd:	89 e5                	mov    %esp,%ebp
801076ff:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107702:	8b 45 0c             	mov    0xc(%ebp),%eax
80107705:	48                   	dec    %eax
80107706:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010770a:	8b 45 08             	mov    0x8(%ebp),%eax
8010770d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107711:	8b 45 08             	mov    0x8(%ebp),%eax
80107714:	c1 e8 10             	shr    $0x10,%eax
80107717:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
8010771b:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010771e:	0f 01 10             	lgdtl  (%eax)
}
80107721:	c9                   	leave  
80107722:	c3                   	ret    

80107723 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80107723:	55                   	push   %ebp
80107724:	89 e5                	mov    %esp,%ebp
80107726:	83 ec 04             	sub    $0x4,%esp
80107729:	8b 45 08             	mov    0x8(%ebp),%eax
8010772c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107730:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107733:	0f 00 d8             	ltr    %ax
}
80107736:	c9                   	leave  
80107737:	c3                   	ret    

80107738 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80107738:	55                   	push   %ebp
80107739:	89 e5                	mov    %esp,%ebp
8010773b:	83 ec 04             	sub    $0x4,%esp
8010773e:	8b 45 08             	mov    0x8(%ebp),%eax
80107741:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80107745:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107748:	8e e8                	mov    %eax,%gs
}
8010774a:	c9                   	leave  
8010774b:	c3                   	ret    

8010774c <lcr3>:
  return val;
}

static inline void
lcr3(uint val)
{
8010774c:	55                   	push   %ebp
8010774d:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010774f:	8b 45 08             	mov    0x8(%ebp),%eax
80107752:	0f 22 d8             	mov    %eax,%cr3
}
80107755:	5d                   	pop    %ebp
80107756:	c3                   	ret    

80107757 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107757:	55                   	push   %ebp
80107758:	89 e5                	mov    %esp,%ebp
8010775a:	53                   	push   %ebx
8010775b:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
8010775e:	e8 8e b7 ff ff       	call   80102ef1 <cpunum>
80107763:	89 c2                	mov    %eax,%edx
80107765:	89 d0                	mov    %edx,%eax
80107767:	c1 e0 02             	shl    $0x2,%eax
8010776a:	01 d0                	add    %edx,%eax
8010776c:	01 c0                	add    %eax,%eax
8010776e:	01 d0                	add    %edx,%eax
80107770:	89 c1                	mov    %eax,%ecx
80107772:	c1 e1 04             	shl    $0x4,%ecx
80107775:	01 c8                	add    %ecx,%eax
80107777:	01 d0                	add    %edx,%eax
80107779:	05 40 38 11 80       	add    $0x80113840,%eax
8010777e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107781:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107784:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
8010778a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010778d:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107793:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107796:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
8010779a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010779d:	8a 50 7d             	mov    0x7d(%eax),%dl
801077a0:	83 e2 f0             	and    $0xfffffff0,%edx
801077a3:	83 ca 0a             	or     $0xa,%edx
801077a6:	88 50 7d             	mov    %dl,0x7d(%eax)
801077a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077ac:	8a 50 7d             	mov    0x7d(%eax),%dl
801077af:	83 ca 10             	or     $0x10,%edx
801077b2:	88 50 7d             	mov    %dl,0x7d(%eax)
801077b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077b8:	8a 50 7d             	mov    0x7d(%eax),%dl
801077bb:	83 e2 9f             	and    $0xffffff9f,%edx
801077be:	88 50 7d             	mov    %dl,0x7d(%eax)
801077c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077c4:	8a 50 7d             	mov    0x7d(%eax),%dl
801077c7:	83 ca 80             	or     $0xffffff80,%edx
801077ca:	88 50 7d             	mov    %dl,0x7d(%eax)
801077cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077d0:	8a 50 7e             	mov    0x7e(%eax),%dl
801077d3:	83 ca 0f             	or     $0xf,%edx
801077d6:	88 50 7e             	mov    %dl,0x7e(%eax)
801077d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077dc:	8a 50 7e             	mov    0x7e(%eax),%dl
801077df:	83 e2 ef             	and    $0xffffffef,%edx
801077e2:	88 50 7e             	mov    %dl,0x7e(%eax)
801077e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077e8:	8a 50 7e             	mov    0x7e(%eax),%dl
801077eb:	83 e2 df             	and    $0xffffffdf,%edx
801077ee:	88 50 7e             	mov    %dl,0x7e(%eax)
801077f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077f4:	8a 50 7e             	mov    0x7e(%eax),%dl
801077f7:	83 ca 40             	or     $0x40,%edx
801077fa:	88 50 7e             	mov    %dl,0x7e(%eax)
801077fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107800:	8a 50 7e             	mov    0x7e(%eax),%dl
80107803:	83 ca 80             	or     $0xffffff80,%edx
80107806:	88 50 7e             	mov    %dl,0x7e(%eax)
80107809:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010780c:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107810:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107813:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
8010781a:	ff ff 
8010781c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010781f:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107826:	00 00 
80107828:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010782b:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107832:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107835:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
8010783b:	83 e2 f0             	and    $0xfffffff0,%edx
8010783e:	83 ca 02             	or     $0x2,%edx
80107841:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107847:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010784a:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80107850:	83 ca 10             	or     $0x10,%edx
80107853:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107859:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010785c:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80107862:	83 e2 9f             	and    $0xffffff9f,%edx
80107865:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010786b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010786e:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80107874:	83 ca 80             	or     $0xffffff80,%edx
80107877:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010787d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107880:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80107886:	83 ca 0f             	or     $0xf,%edx
80107889:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010788f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107892:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80107898:	83 e2 ef             	and    $0xffffffef,%edx
8010789b:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801078a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078a4:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
801078aa:	83 e2 df             	and    $0xffffffdf,%edx
801078ad:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801078b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078b6:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
801078bc:	83 ca 40             	or     $0x40,%edx
801078bf:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801078c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078c8:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
801078ce:	83 ca 80             	or     $0xffffff80,%edx
801078d1:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801078d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078da:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801078e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078e4:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801078eb:	ff ff 
801078ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078f0:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801078f7:	00 00 
801078f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078fc:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107903:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107906:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
8010790c:	83 e2 f0             	and    $0xfffffff0,%edx
8010790f:	83 ca 0a             	or     $0xa,%edx
80107912:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107918:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010791b:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80107921:	83 ca 10             	or     $0x10,%edx
80107924:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010792a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010792d:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80107933:	83 ca 60             	or     $0x60,%edx
80107936:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010793c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010793f:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80107945:	83 ca 80             	or     $0xffffff80,%edx
80107948:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010794e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107951:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80107957:	83 ca 0f             	or     $0xf,%edx
8010795a:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107960:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107963:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80107969:	83 e2 ef             	and    $0xffffffef,%edx
8010796c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107972:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107975:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
8010797b:	83 e2 df             	and    $0xffffffdf,%edx
8010797e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107984:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107987:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
8010798d:	83 ca 40             	or     $0x40,%edx
80107990:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107996:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107999:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
8010799f:	83 ca 80             	or     $0xffffff80,%edx
801079a2:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801079a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ab:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801079b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079b5:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
801079bc:	ff ff 
801079be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079c1:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
801079c8:	00 00 
801079ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079cd:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
801079d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079d7:	8a 90 9d 00 00 00    	mov    0x9d(%eax),%dl
801079dd:	83 e2 f0             	and    $0xfffffff0,%edx
801079e0:	83 ca 02             	or     $0x2,%edx
801079e3:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801079e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ec:	8a 90 9d 00 00 00    	mov    0x9d(%eax),%dl
801079f2:	83 ca 10             	or     $0x10,%edx
801079f5:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801079fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079fe:	8a 90 9d 00 00 00    	mov    0x9d(%eax),%dl
80107a04:	83 ca 60             	or     $0x60,%edx
80107a07:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107a0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a10:	8a 90 9d 00 00 00    	mov    0x9d(%eax),%dl
80107a16:	83 ca 80             	or     $0xffffff80,%edx
80107a19:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a22:	8a 90 9e 00 00 00    	mov    0x9e(%eax),%dl
80107a28:	83 ca 0f             	or     $0xf,%edx
80107a2b:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107a31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a34:	8a 90 9e 00 00 00    	mov    0x9e(%eax),%dl
80107a3a:	83 e2 ef             	and    $0xffffffef,%edx
80107a3d:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a46:	8a 90 9e 00 00 00    	mov    0x9e(%eax),%dl
80107a4c:	83 e2 df             	and    $0xffffffdf,%edx
80107a4f:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107a55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a58:	8a 90 9e 00 00 00    	mov    0x9e(%eax),%dl
80107a5e:	83 ca 40             	or     $0x40,%edx
80107a61:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107a67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a6a:	8a 90 9e 00 00 00    	mov    0x9e(%eax),%dl
80107a70:	83 ca 80             	or     $0xffffff80,%edx
80107a73:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107a79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a7c:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu and proc -- these are private per cpu.
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107a83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a86:	05 b4 00 00 00       	add    $0xb4,%eax
80107a8b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107a8e:	81 c2 b4 00 00 00    	add    $0xb4,%edx
80107a94:	c1 ea 10             	shr    $0x10,%edx
80107a97:	88 d1                	mov    %dl,%cl
80107a99:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107a9c:	81 c2 b4 00 00 00    	add    $0xb4,%edx
80107aa2:	c1 ea 18             	shr    $0x18,%edx
80107aa5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80107aa8:	66 c7 83 88 00 00 00 	movw   $0x0,0x88(%ebx)
80107aaf:	00 00 
80107ab1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80107ab4:	66 89 83 8a 00 00 00 	mov    %ax,0x8a(%ebx)
80107abb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107abe:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
80107ac4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ac7:	8a 88 8d 00 00 00    	mov    0x8d(%eax),%cl
80107acd:	83 e1 f0             	and    $0xfffffff0,%ecx
80107ad0:	83 c9 02             	or     $0x2,%ecx
80107ad3:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107adc:	8a 88 8d 00 00 00    	mov    0x8d(%eax),%cl
80107ae2:	83 c9 10             	or     $0x10,%ecx
80107ae5:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107aeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aee:	8a 88 8d 00 00 00    	mov    0x8d(%eax),%cl
80107af4:	83 e1 9f             	and    $0xffffff9f,%ecx
80107af7:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107afd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b00:	8a 88 8d 00 00 00    	mov    0x8d(%eax),%cl
80107b06:	83 c9 80             	or     $0xffffff80,%ecx
80107b09:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107b0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b12:	8a 88 8e 00 00 00    	mov    0x8e(%eax),%cl
80107b18:	83 e1 f0             	and    $0xfffffff0,%ecx
80107b1b:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107b21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b24:	8a 88 8e 00 00 00    	mov    0x8e(%eax),%cl
80107b2a:	83 e1 ef             	and    $0xffffffef,%ecx
80107b2d:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107b33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b36:	8a 88 8e 00 00 00    	mov    0x8e(%eax),%cl
80107b3c:	83 e1 df             	and    $0xffffffdf,%ecx
80107b3f:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107b45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b48:	8a 88 8e 00 00 00    	mov    0x8e(%eax),%cl
80107b4e:	83 c9 40             	or     $0x40,%ecx
80107b51:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107b57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b5a:	8a 88 8e 00 00 00    	mov    0x8e(%eax),%cl
80107b60:	83 c9 80             	or     $0xffffff80,%ecx
80107b63:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107b69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b6c:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107b72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b75:	83 c0 70             	add    $0x70,%eax
80107b78:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
80107b7f:	00 
80107b80:	89 04 24             	mov    %eax,(%esp)
80107b83:	e8 74 fb ff ff       	call   801076fc <lgdt>
  loadgs(SEG_KCPU << 3);
80107b88:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
80107b8f:	e8 a4 fb ff ff       	call   80107738 <loadgs>

  // Initialize cpu-local storage.
  cpu = c;
80107b94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b97:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107b9d:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107ba4:	00 00 00 00 
}
80107ba8:	83 c4 24             	add    $0x24,%esp
80107bab:	5b                   	pop    %ebx
80107bac:	5d                   	pop    %ebp
80107bad:	c3                   	ret    

80107bae <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107bae:	55                   	push   %ebp
80107baf:	89 e5                	mov    %esp,%ebp
80107bb1:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107bb4:	8b 45 0c             	mov    0xc(%ebp),%eax
80107bb7:	c1 e8 16             	shr    $0x16,%eax
80107bba:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107bc1:	8b 45 08             	mov    0x8(%ebp),%eax
80107bc4:	01 d0                	add    %edx,%eax
80107bc6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107bc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107bcc:	8b 00                	mov    (%eax),%eax
80107bce:	83 e0 01             	and    $0x1,%eax
80107bd1:	85 c0                	test   %eax,%eax
80107bd3:	74 14                	je     80107be9 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107bd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107bd8:	8b 00                	mov    (%eax),%eax
80107bda:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107bdf:	05 00 00 00 80       	add    $0x80000000,%eax
80107be4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107be7:	eb 48                	jmp    80107c31 <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107be9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107bed:	74 0e                	je     80107bfd <walkpgdir+0x4f>
80107bef:	e8 6f af ff ff       	call   80102b63 <kalloc>
80107bf4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107bf7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107bfb:	75 07                	jne    80107c04 <walkpgdir+0x56>
      return 0;
80107bfd:	b8 00 00 00 00       	mov    $0x0,%eax
80107c02:	eb 44                	jmp    80107c48 <walkpgdir+0x9a>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107c04:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107c0b:	00 
80107c0c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107c13:	00 
80107c14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c17:	89 04 24             	mov    %eax,(%esp)
80107c1a:	e8 6b d5 ff ff       	call   8010518a <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107c1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c22:	05 00 00 00 80       	add    $0x80000000,%eax
80107c27:	83 c8 07             	or     $0x7,%eax
80107c2a:	89 c2                	mov    %eax,%edx
80107c2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c2f:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107c31:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c34:	c1 e8 0c             	shr    $0xc,%eax
80107c37:	25 ff 03 00 00       	and    $0x3ff,%eax
80107c3c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107c43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c46:	01 d0                	add    %edx,%eax
}
80107c48:	c9                   	leave  
80107c49:	c3                   	ret    

80107c4a <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107c4a:	55                   	push   %ebp
80107c4b:	89 e5                	mov    %esp,%ebp
80107c4d:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107c50:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c53:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c58:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107c5b:	8b 55 0c             	mov    0xc(%ebp),%edx
80107c5e:	8b 45 10             	mov    0x10(%ebp),%eax
80107c61:	01 d0                	add    %edx,%eax
80107c63:	48                   	dec    %eax
80107c64:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c69:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107c6c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80107c73:	00 
80107c74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c77:	89 44 24 04          	mov    %eax,0x4(%esp)
80107c7b:	8b 45 08             	mov    0x8(%ebp),%eax
80107c7e:	89 04 24             	mov    %eax,(%esp)
80107c81:	e8 28 ff ff ff       	call   80107bae <walkpgdir>
80107c86:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107c89:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107c8d:	75 07                	jne    80107c96 <mappages+0x4c>
      return -1;
80107c8f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107c94:	eb 48                	jmp    80107cde <mappages+0x94>
    if(*pte & PTE_P)
80107c96:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c99:	8b 00                	mov    (%eax),%eax
80107c9b:	83 e0 01             	and    $0x1,%eax
80107c9e:	85 c0                	test   %eax,%eax
80107ca0:	74 0c                	je     80107cae <mappages+0x64>
      panic("remap");
80107ca2:	c7 04 24 3c 8b 10 80 	movl   $0x80108b3c,(%esp)
80107ca9:	e8 a6 88 ff ff       	call   80100554 <panic>
    *pte = pa | perm | PTE_P;
80107cae:	8b 45 18             	mov    0x18(%ebp),%eax
80107cb1:	0b 45 14             	or     0x14(%ebp),%eax
80107cb4:	83 c8 01             	or     $0x1,%eax
80107cb7:	89 c2                	mov    %eax,%edx
80107cb9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107cbc:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107cbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc1:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107cc4:	75 08                	jne    80107cce <mappages+0x84>
      break;
80107cc6:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80107cc7:	b8 00 00 00 00       	mov    $0x0,%eax
80107ccc:	eb 10                	jmp    80107cde <mappages+0x94>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
80107cce:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107cd5:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80107cdc:	eb 8e                	jmp    80107c6c <mappages+0x22>
  return 0;
}
80107cde:	c9                   	leave  
80107cdf:	c3                   	ret    

80107ce0 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107ce0:	55                   	push   %ebp
80107ce1:	89 e5                	mov    %esp,%ebp
80107ce3:	53                   	push   %ebx
80107ce4:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107ce7:	e8 77 ae ff ff       	call   80102b63 <kalloc>
80107cec:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107cef:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107cf3:	75 07                	jne    80107cfc <setupkvm+0x1c>
    return 0;
80107cf5:	b8 00 00 00 00       	mov    $0x0,%eax
80107cfa:	eb 79                	jmp    80107d75 <setupkvm+0x95>
  memset(pgdir, 0, PGSIZE);
80107cfc:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107d03:	00 
80107d04:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107d0b:	00 
80107d0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d0f:	89 04 24             	mov    %eax,(%esp)
80107d12:	e8 73 d4 ff ff       	call   8010518a <memset>
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107d17:	c7 45 f4 c0 b4 10 80 	movl   $0x8010b4c0,-0xc(%ebp)
80107d1e:	eb 49                	jmp    80107d69 <setupkvm+0x89>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107d20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d23:	8b 48 0c             	mov    0xc(%eax),%ecx
80107d26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d29:	8b 50 04             	mov    0x4(%eax),%edx
80107d2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d2f:	8b 58 08             	mov    0x8(%eax),%ebx
80107d32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d35:	8b 40 04             	mov    0x4(%eax),%eax
80107d38:	29 c3                	sub    %eax,%ebx
80107d3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d3d:	8b 00                	mov    (%eax),%eax
80107d3f:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80107d43:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107d47:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107d4b:	89 44 24 04          	mov    %eax,0x4(%esp)
80107d4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d52:	89 04 24             	mov    %eax,(%esp)
80107d55:	e8 f0 fe ff ff       	call   80107c4a <mappages>
80107d5a:	85 c0                	test   %eax,%eax
80107d5c:	79 07                	jns    80107d65 <setupkvm+0x85>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80107d5e:	b8 00 00 00 00       	mov    $0x0,%eax
80107d63:	eb 10                	jmp    80107d75 <setupkvm+0x95>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107d65:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107d69:	81 7d f4 00 b5 10 80 	cmpl   $0x8010b500,-0xc(%ebp)
80107d70:	72 ae                	jb     80107d20 <setupkvm+0x40>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80107d72:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107d75:	83 c4 34             	add    $0x34,%esp
80107d78:	5b                   	pop    %ebx
80107d79:	5d                   	pop    %ebp
80107d7a:	c3                   	ret    

80107d7b <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107d7b:	55                   	push   %ebp
80107d7c:	89 e5                	mov    %esp,%ebp
80107d7e:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107d81:	e8 5a ff ff ff       	call   80107ce0 <setupkvm>
80107d86:	a3 c4 65 11 80       	mov    %eax,0x801165c4
  switchkvm();
80107d8b:	e8 02 00 00 00       	call   80107d92 <switchkvm>
}
80107d90:	c9                   	leave  
80107d91:	c3                   	ret    

80107d92 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107d92:	55                   	push   %ebp
80107d93:	89 e5                	mov    %esp,%ebp
80107d95:	83 ec 04             	sub    $0x4,%esp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107d98:	a1 c4 65 11 80       	mov    0x801165c4,%eax
80107d9d:	05 00 00 00 80       	add    $0x80000000,%eax
80107da2:	89 04 24             	mov    %eax,(%esp)
80107da5:	e8 a2 f9 ff ff       	call   8010774c <lcr3>
}
80107daa:	c9                   	leave  
80107dab:	c3                   	ret    

80107dac <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107dac:	55                   	push   %ebp
80107dad:	89 e5                	mov    %esp,%ebp
80107daf:	53                   	push   %ebx
80107db0:	83 ec 14             	sub    $0x14,%esp
  pushcli();
80107db3:	e8 c4 d2 ff ff       	call   8010507c <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80107db8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107dbe:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107dc5:	83 c2 08             	add    $0x8,%edx
80107dc8:	65 8b 0d 00 00 00 00 	mov    %gs:0x0,%ecx
80107dcf:	83 c1 08             	add    $0x8,%ecx
80107dd2:	c1 e9 10             	shr    $0x10,%ecx
80107dd5:	88 cb                	mov    %cl,%bl
80107dd7:	65 8b 0d 00 00 00 00 	mov    %gs:0x0,%ecx
80107dde:	83 c1 08             	add    $0x8,%ecx
80107de1:	c1 e9 18             	shr    $0x18,%ecx
80107de4:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80107deb:	67 00 
80107ded:	66 89 90 a2 00 00 00 	mov    %dx,0xa2(%eax)
80107df4:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80107dfa:	8a 90 a5 00 00 00    	mov    0xa5(%eax),%dl
80107e00:	83 e2 f0             	and    $0xfffffff0,%edx
80107e03:	83 ca 09             	or     $0x9,%edx
80107e06:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107e0c:	8a 90 a5 00 00 00    	mov    0xa5(%eax),%dl
80107e12:	83 ca 10             	or     $0x10,%edx
80107e15:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107e1b:	8a 90 a5 00 00 00    	mov    0xa5(%eax),%dl
80107e21:	83 e2 9f             	and    $0xffffff9f,%edx
80107e24:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107e2a:	8a 90 a5 00 00 00    	mov    0xa5(%eax),%dl
80107e30:	83 ca 80             	or     $0xffffff80,%edx
80107e33:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107e39:	8a 90 a6 00 00 00    	mov    0xa6(%eax),%dl
80107e3f:	83 e2 f0             	and    $0xfffffff0,%edx
80107e42:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107e48:	8a 90 a6 00 00 00    	mov    0xa6(%eax),%dl
80107e4e:	83 e2 ef             	and    $0xffffffef,%edx
80107e51:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107e57:	8a 90 a6 00 00 00    	mov    0xa6(%eax),%dl
80107e5d:	83 e2 df             	and    $0xffffffdf,%edx
80107e60:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107e66:	8a 90 a6 00 00 00    	mov    0xa6(%eax),%dl
80107e6c:	83 ca 40             	or     $0x40,%edx
80107e6f:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107e75:	8a 90 a6 00 00 00    	mov    0xa6(%eax),%dl
80107e7b:	83 e2 7f             	and    $0x7f,%edx
80107e7e:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107e84:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80107e8a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107e90:	8a 90 a5 00 00 00    	mov    0xa5(%eax),%dl
80107e96:	83 e2 ef             	and    $0xffffffef,%edx
80107e99:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80107e9f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107ea5:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80107eab:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107eb1:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80107eb8:	8b 52 08             	mov    0x8(%edx),%edx
80107ebb:	81 c2 00 10 00 00    	add    $0x1000,%edx
80107ec1:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  cpu->ts.iomb = (ushort) 0xFFFF;
80107ec4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107eca:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107ed0:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
80107ed7:	e8 47 f8 ff ff       	call   80107723 <ltr>
  if(p->pgdir == 0)
80107edc:	8b 45 08             	mov    0x8(%ebp),%eax
80107edf:	8b 40 04             	mov    0x4(%eax),%eax
80107ee2:	85 c0                	test   %eax,%eax
80107ee4:	75 0c                	jne    80107ef2 <switchuvm+0x146>
    panic("switchuvm: no pgdir");
80107ee6:	c7 04 24 42 8b 10 80 	movl   $0x80108b42,(%esp)
80107eed:	e8 62 86 ff ff       	call   80100554 <panic>
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107ef2:	8b 45 08             	mov    0x8(%ebp),%eax
80107ef5:	8b 40 04             	mov    0x4(%eax),%eax
80107ef8:	05 00 00 00 80       	add    $0x80000000,%eax
80107efd:	89 04 24             	mov    %eax,(%esp)
80107f00:	e8 47 f8 ff ff       	call   8010774c <lcr3>
  popcli();
80107f05:	e8 c6 d1 ff ff       	call   801050d0 <popcli>
}
80107f0a:	83 c4 14             	add    $0x14,%esp
80107f0d:	5b                   	pop    %ebx
80107f0e:	5d                   	pop    %ebp
80107f0f:	c3                   	ret    

80107f10 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107f10:	55                   	push   %ebp
80107f11:	89 e5                	mov    %esp,%ebp
80107f13:	83 ec 38             	sub    $0x38,%esp
  char *mem;

  if(sz >= PGSIZE)
80107f16:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107f1d:	76 0c                	jbe    80107f2b <inituvm+0x1b>
    panic("inituvm: more than a page");
80107f1f:	c7 04 24 56 8b 10 80 	movl   $0x80108b56,(%esp)
80107f26:	e8 29 86 ff ff       	call   80100554 <panic>
  mem = kalloc();
80107f2b:	e8 33 ac ff ff       	call   80102b63 <kalloc>
80107f30:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107f33:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107f3a:	00 
80107f3b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107f42:	00 
80107f43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f46:	89 04 24             	mov    %eax,(%esp)
80107f49:	e8 3c d2 ff ff       	call   8010518a <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107f4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f51:	05 00 00 00 80       	add    $0x80000000,%eax
80107f56:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80107f5d:	00 
80107f5e:	89 44 24 0c          	mov    %eax,0xc(%esp)
80107f62:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107f69:	00 
80107f6a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107f71:	00 
80107f72:	8b 45 08             	mov    0x8(%ebp),%eax
80107f75:	89 04 24             	mov    %eax,(%esp)
80107f78:	e8 cd fc ff ff       	call   80107c4a <mappages>
  memmove(mem, init, sz);
80107f7d:	8b 45 10             	mov    0x10(%ebp),%eax
80107f80:	89 44 24 08          	mov    %eax,0x8(%esp)
80107f84:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f87:	89 44 24 04          	mov    %eax,0x4(%esp)
80107f8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f8e:	89 04 24             	mov    %eax,(%esp)
80107f91:	e8 bd d2 ff ff       	call   80105253 <memmove>
}
80107f96:	c9                   	leave  
80107f97:	c3                   	ret    

80107f98 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107f98:	55                   	push   %ebp
80107f99:	89 e5                	mov    %esp,%ebp
80107f9b:	83 ec 28             	sub    $0x28,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107f9e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fa1:	25 ff 0f 00 00       	and    $0xfff,%eax
80107fa6:	85 c0                	test   %eax,%eax
80107fa8:	74 0c                	je     80107fb6 <loaduvm+0x1e>
    panic("loaduvm: addr must be page aligned");
80107faa:	c7 04 24 70 8b 10 80 	movl   $0x80108b70,(%esp)
80107fb1:	e8 9e 85 ff ff       	call   80100554 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107fb6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107fbd:	e9 a6 00 00 00       	jmp    80108068 <loaduvm+0xd0>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107fc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fc5:	8b 55 0c             	mov    0xc(%ebp),%edx
80107fc8:	01 d0                	add    %edx,%eax
80107fca:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80107fd1:	00 
80107fd2:	89 44 24 04          	mov    %eax,0x4(%esp)
80107fd6:	8b 45 08             	mov    0x8(%ebp),%eax
80107fd9:	89 04 24             	mov    %eax,(%esp)
80107fdc:	e8 cd fb ff ff       	call   80107bae <walkpgdir>
80107fe1:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107fe4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107fe8:	75 0c                	jne    80107ff6 <loaduvm+0x5e>
      panic("loaduvm: address should exist");
80107fea:	c7 04 24 93 8b 10 80 	movl   $0x80108b93,(%esp)
80107ff1:	e8 5e 85 ff ff       	call   80100554 <panic>
    pa = PTE_ADDR(*pte);
80107ff6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ff9:	8b 00                	mov    (%eax),%eax
80107ffb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108000:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108003:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108006:	8b 55 18             	mov    0x18(%ebp),%edx
80108009:	29 c2                	sub    %eax,%edx
8010800b:	89 d0                	mov    %edx,%eax
8010800d:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108012:	77 0f                	ja     80108023 <loaduvm+0x8b>
      n = sz - i;
80108014:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108017:	8b 55 18             	mov    0x18(%ebp),%edx
8010801a:	29 c2                	sub    %eax,%edx
8010801c:	89 d0                	mov    %edx,%eax
8010801e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108021:	eb 07                	jmp    8010802a <loaduvm+0x92>
    else
      n = PGSIZE;
80108023:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
8010802a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010802d:	8b 55 14             	mov    0x14(%ebp),%edx
80108030:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80108033:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108036:	05 00 00 00 80       	add    $0x80000000,%eax
8010803b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010803e:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108042:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80108046:	89 44 24 04          	mov    %eax,0x4(%esp)
8010804a:	8b 45 10             	mov    0x10(%ebp),%eax
8010804d:	89 04 24             	mov    %eax,(%esp)
80108050:	e8 4d 9d ff ff       	call   80101da2 <readi>
80108055:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108058:	74 07                	je     80108061 <loaduvm+0xc9>
      return -1;
8010805a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010805f:	eb 18                	jmp    80108079 <loaduvm+0xe1>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108061:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108068:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010806b:	3b 45 18             	cmp    0x18(%ebp),%eax
8010806e:	0f 82 4e ff ff ff    	jb     80107fc2 <loaduvm+0x2a>
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108074:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108079:	c9                   	leave  
8010807a:	c3                   	ret    

8010807b <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010807b:	55                   	push   %ebp
8010807c:	89 e5                	mov    %esp,%ebp
8010807e:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108081:	8b 45 10             	mov    0x10(%ebp),%eax
80108084:	85 c0                	test   %eax,%eax
80108086:	79 0a                	jns    80108092 <allocuvm+0x17>
    return 0;
80108088:	b8 00 00 00 00       	mov    $0x0,%eax
8010808d:	e9 fd 00 00 00       	jmp    8010818f <allocuvm+0x114>
  if(newsz < oldsz)
80108092:	8b 45 10             	mov    0x10(%ebp),%eax
80108095:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108098:	73 08                	jae    801080a2 <allocuvm+0x27>
    return oldsz;
8010809a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010809d:	e9 ed 00 00 00       	jmp    8010818f <allocuvm+0x114>

  a = PGROUNDUP(oldsz);
801080a2:	8b 45 0c             	mov    0xc(%ebp),%eax
801080a5:	05 ff 0f 00 00       	add    $0xfff,%eax
801080aa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080af:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801080b2:	e9 c9 00 00 00       	jmp    80108180 <allocuvm+0x105>
    mem = kalloc();
801080b7:	e8 a7 aa ff ff       	call   80102b63 <kalloc>
801080bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801080bf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801080c3:	75 2f                	jne    801080f4 <allocuvm+0x79>
      cprintf("allocuvm out of memory\n");
801080c5:	c7 04 24 b1 8b 10 80 	movl   $0x80108bb1,(%esp)
801080cc:	e8 f0 82 ff ff       	call   801003c1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801080d1:	8b 45 0c             	mov    0xc(%ebp),%eax
801080d4:	89 44 24 08          	mov    %eax,0x8(%esp)
801080d8:	8b 45 10             	mov    0x10(%ebp),%eax
801080db:	89 44 24 04          	mov    %eax,0x4(%esp)
801080df:	8b 45 08             	mov    0x8(%ebp),%eax
801080e2:	89 04 24             	mov    %eax,(%esp)
801080e5:	e8 a7 00 00 00       	call   80108191 <deallocuvm>
      return 0;
801080ea:	b8 00 00 00 00       	mov    $0x0,%eax
801080ef:	e9 9b 00 00 00       	jmp    8010818f <allocuvm+0x114>
    }
    memset(mem, 0, PGSIZE);
801080f4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801080fb:	00 
801080fc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108103:	00 
80108104:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108107:	89 04 24             	mov    %eax,(%esp)
8010810a:	e8 7b d0 ff ff       	call   8010518a <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
8010810f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108112:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108118:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010811b:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108122:	00 
80108123:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108127:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010812e:	00 
8010812f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108133:	8b 45 08             	mov    0x8(%ebp),%eax
80108136:	89 04 24             	mov    %eax,(%esp)
80108139:	e8 0c fb ff ff       	call   80107c4a <mappages>
8010813e:	85 c0                	test   %eax,%eax
80108140:	79 37                	jns    80108179 <allocuvm+0xfe>
      cprintf("allocuvm out of memory (2)\n");
80108142:	c7 04 24 c9 8b 10 80 	movl   $0x80108bc9,(%esp)
80108149:	e8 73 82 ff ff       	call   801003c1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
8010814e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108151:	89 44 24 08          	mov    %eax,0x8(%esp)
80108155:	8b 45 10             	mov    0x10(%ebp),%eax
80108158:	89 44 24 04          	mov    %eax,0x4(%esp)
8010815c:	8b 45 08             	mov    0x8(%ebp),%eax
8010815f:	89 04 24             	mov    %eax,(%esp)
80108162:	e8 2a 00 00 00       	call   80108191 <deallocuvm>
      kfree(mem);
80108167:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010816a:	89 04 24             	mov    %eax,(%esp)
8010816d:	e8 5b a9 ff ff       	call   80102acd <kfree>
      return 0;
80108172:	b8 00 00 00 00       	mov    $0x0,%eax
80108177:	eb 16                	jmp    8010818f <allocuvm+0x114>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108179:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108180:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108183:	3b 45 10             	cmp    0x10(%ebp),%eax
80108186:	0f 82 2b ff ff ff    	jb     801080b7 <allocuvm+0x3c>
      deallocuvm(pgdir, newsz, oldsz);
      kfree(mem);
      return 0;
    }
  }
  return newsz;
8010818c:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010818f:	c9                   	leave  
80108190:	c3                   	ret    

80108191 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108191:	55                   	push   %ebp
80108192:	89 e5                	mov    %esp,%ebp
80108194:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108197:	8b 45 10             	mov    0x10(%ebp),%eax
8010819a:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010819d:	72 08                	jb     801081a7 <deallocuvm+0x16>
    return oldsz;
8010819f:	8b 45 0c             	mov    0xc(%ebp),%eax
801081a2:	e9 9e 00 00 00       	jmp    80108245 <deallocuvm+0xb4>

  a = PGROUNDUP(newsz);
801081a7:	8b 45 10             	mov    0x10(%ebp),%eax
801081aa:	05 ff 0f 00 00       	add    $0xfff,%eax
801081af:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801081b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801081b7:	eb 7d                	jmp    80108236 <deallocuvm+0xa5>
    pte = walkpgdir(pgdir, (char*)a, 0);
801081b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081bc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801081c3:	00 
801081c4:	89 44 24 04          	mov    %eax,0x4(%esp)
801081c8:	8b 45 08             	mov    0x8(%ebp),%eax
801081cb:	89 04 24             	mov    %eax,(%esp)
801081ce:	e8 db f9 ff ff       	call   80107bae <walkpgdir>
801081d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801081d6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801081da:	75 09                	jne    801081e5 <deallocuvm+0x54>
      a += (NPTENTRIES - 1) * PGSIZE;
801081dc:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
801081e3:	eb 4a                	jmp    8010822f <deallocuvm+0x9e>
    else if((*pte & PTE_P) != 0){
801081e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081e8:	8b 00                	mov    (%eax),%eax
801081ea:	83 e0 01             	and    $0x1,%eax
801081ed:	85 c0                	test   %eax,%eax
801081ef:	74 3e                	je     8010822f <deallocuvm+0x9e>
      pa = PTE_ADDR(*pte);
801081f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081f4:	8b 00                	mov    (%eax),%eax
801081f6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801081fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801081fe:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108202:	75 0c                	jne    80108210 <deallocuvm+0x7f>
        panic("kfree");
80108204:	c7 04 24 e5 8b 10 80 	movl   $0x80108be5,(%esp)
8010820b:	e8 44 83 ff ff       	call   80100554 <panic>
      char *v = P2V(pa);
80108210:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108213:	05 00 00 00 80       	add    $0x80000000,%eax
80108218:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
8010821b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010821e:	89 04 24             	mov    %eax,(%esp)
80108221:	e8 a7 a8 ff ff       	call   80102acd <kfree>
      *pte = 0;
80108226:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108229:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
8010822f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108236:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108239:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010823c:	0f 82 77 ff ff ff    	jb     801081b9 <deallocuvm+0x28>
      char *v = P2V(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108242:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108245:	c9                   	leave  
80108246:	c3                   	ret    

80108247 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108247:	55                   	push   %ebp
80108248:	89 e5                	mov    %esp,%ebp
8010824a:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
8010824d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108251:	75 0c                	jne    8010825f <freevm+0x18>
    panic("freevm: no pgdir");
80108253:	c7 04 24 eb 8b 10 80 	movl   $0x80108beb,(%esp)
8010825a:	e8 f5 82 ff ff       	call   80100554 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
8010825f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108266:	00 
80108267:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
8010826e:	80 
8010826f:	8b 45 08             	mov    0x8(%ebp),%eax
80108272:	89 04 24             	mov    %eax,(%esp)
80108275:	e8 17 ff ff ff       	call   80108191 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
8010827a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108281:	eb 44                	jmp    801082c7 <freevm+0x80>
    if(pgdir[i] & PTE_P){
80108283:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108286:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010828d:	8b 45 08             	mov    0x8(%ebp),%eax
80108290:	01 d0                	add    %edx,%eax
80108292:	8b 00                	mov    (%eax),%eax
80108294:	83 e0 01             	and    $0x1,%eax
80108297:	85 c0                	test   %eax,%eax
80108299:	74 29                	je     801082c4 <freevm+0x7d>
      char * v = P2V(PTE_ADDR(pgdir[i]));
8010829b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010829e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801082a5:	8b 45 08             	mov    0x8(%ebp),%eax
801082a8:	01 d0                	add    %edx,%eax
801082aa:	8b 00                	mov    (%eax),%eax
801082ac:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801082b1:	05 00 00 00 80       	add    $0x80000000,%eax
801082b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801082b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082bc:	89 04 24             	mov    %eax,(%esp)
801082bf:	e8 09 a8 ff ff       	call   80102acd <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
801082c4:	ff 45 f4             	incl   -0xc(%ebp)
801082c7:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801082ce:	76 b3                	jbe    80108283 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
801082d0:	8b 45 08             	mov    0x8(%ebp),%eax
801082d3:	89 04 24             	mov    %eax,(%esp)
801082d6:	e8 f2 a7 ff ff       	call   80102acd <kfree>
}
801082db:	c9                   	leave  
801082dc:	c3                   	ret    

801082dd <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801082dd:	55                   	push   %ebp
801082de:	89 e5                	mov    %esp,%ebp
801082e0:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801082e3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801082ea:	00 
801082eb:	8b 45 0c             	mov    0xc(%ebp),%eax
801082ee:	89 44 24 04          	mov    %eax,0x4(%esp)
801082f2:	8b 45 08             	mov    0x8(%ebp),%eax
801082f5:	89 04 24             	mov    %eax,(%esp)
801082f8:	e8 b1 f8 ff ff       	call   80107bae <walkpgdir>
801082fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108300:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108304:	75 0c                	jne    80108312 <clearpteu+0x35>
    panic("clearpteu");
80108306:	c7 04 24 fc 8b 10 80 	movl   $0x80108bfc,(%esp)
8010830d:	e8 42 82 ff ff       	call   80100554 <panic>
  *pte &= ~PTE_U;
80108312:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108315:	8b 00                	mov    (%eax),%eax
80108317:	83 e0 fb             	and    $0xfffffffb,%eax
8010831a:	89 c2                	mov    %eax,%edx
8010831c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010831f:	89 10                	mov    %edx,(%eax)
}
80108321:	c9                   	leave  
80108322:	c3                   	ret    

80108323 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108323:	55                   	push   %ebp
80108324:	89 e5                	mov    %esp,%ebp
80108326:	83 ec 48             	sub    $0x48,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108329:	e8 b2 f9 ff ff       	call   80107ce0 <setupkvm>
8010832e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108331:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108335:	75 0a                	jne    80108341 <copyuvm+0x1e>
    return 0;
80108337:	b8 00 00 00 00       	mov    $0x0,%eax
8010833c:	e9 f8 00 00 00       	jmp    80108439 <copyuvm+0x116>
  for(i = 0; i < sz; i += PGSIZE){
80108341:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108348:	e9 cb 00 00 00       	jmp    80108418 <copyuvm+0xf5>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
8010834d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108350:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108357:	00 
80108358:	89 44 24 04          	mov    %eax,0x4(%esp)
8010835c:	8b 45 08             	mov    0x8(%ebp),%eax
8010835f:	89 04 24             	mov    %eax,(%esp)
80108362:	e8 47 f8 ff ff       	call   80107bae <walkpgdir>
80108367:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010836a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010836e:	75 0c                	jne    8010837c <copyuvm+0x59>
      panic("copyuvm: pte should exist");
80108370:	c7 04 24 06 8c 10 80 	movl   $0x80108c06,(%esp)
80108377:	e8 d8 81 ff ff       	call   80100554 <panic>
    if(!(*pte & PTE_P))
8010837c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010837f:	8b 00                	mov    (%eax),%eax
80108381:	83 e0 01             	and    $0x1,%eax
80108384:	85 c0                	test   %eax,%eax
80108386:	75 0c                	jne    80108394 <copyuvm+0x71>
      panic("copyuvm: page not present");
80108388:	c7 04 24 20 8c 10 80 	movl   $0x80108c20,(%esp)
8010838f:	e8 c0 81 ff ff       	call   80100554 <panic>
    pa = PTE_ADDR(*pte);
80108394:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108397:	8b 00                	mov    (%eax),%eax
80108399:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010839e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801083a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083a4:	8b 00                	mov    (%eax),%eax
801083a6:	25 ff 0f 00 00       	and    $0xfff,%eax
801083ab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801083ae:	e8 b0 a7 ff ff       	call   80102b63 <kalloc>
801083b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
801083b6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801083ba:	75 02                	jne    801083be <copyuvm+0x9b>
      goto bad;
801083bc:	eb 6b                	jmp    80108429 <copyuvm+0x106>
    memmove(mem, (char*)P2V(pa), PGSIZE);
801083be:	8b 45 e8             	mov    -0x18(%ebp),%eax
801083c1:	05 00 00 00 80       	add    $0x80000000,%eax
801083c6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801083cd:	00 
801083ce:	89 44 24 04          	mov    %eax,0x4(%esp)
801083d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801083d5:	89 04 24             	mov    %eax,(%esp)
801083d8:	e8 76 ce ff ff       	call   80105253 <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
801083dd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801083e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801083e3:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
801083e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083ec:	89 54 24 10          	mov    %edx,0x10(%esp)
801083f0:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801083f4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801083fb:	00 
801083fc:	89 44 24 04          	mov    %eax,0x4(%esp)
80108400:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108403:	89 04 24             	mov    %eax,(%esp)
80108406:	e8 3f f8 ff ff       	call   80107c4a <mappages>
8010840b:	85 c0                	test   %eax,%eax
8010840d:	79 02                	jns    80108411 <copyuvm+0xee>
      goto bad;
8010840f:	eb 18                	jmp    80108429 <copyuvm+0x106>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108411:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108418:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010841b:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010841e:	0f 82 29 ff ff ff    	jb     8010834d <copyuvm+0x2a>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
      goto bad;
  }
  return d;
80108424:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108427:	eb 10                	jmp    80108439 <copyuvm+0x116>

bad:
  freevm(d);
80108429:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010842c:	89 04 24             	mov    %eax,(%esp)
8010842f:	e8 13 fe ff ff       	call   80108247 <freevm>
  return 0;
80108434:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108439:	c9                   	leave  
8010843a:	c3                   	ret    

8010843b <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010843b:	55                   	push   %ebp
8010843c:	89 e5                	mov    %esp,%ebp
8010843e:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108441:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108448:	00 
80108449:	8b 45 0c             	mov    0xc(%ebp),%eax
8010844c:	89 44 24 04          	mov    %eax,0x4(%esp)
80108450:	8b 45 08             	mov    0x8(%ebp),%eax
80108453:	89 04 24             	mov    %eax,(%esp)
80108456:	e8 53 f7 ff ff       	call   80107bae <walkpgdir>
8010845b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
8010845e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108461:	8b 00                	mov    (%eax),%eax
80108463:	83 e0 01             	and    $0x1,%eax
80108466:	85 c0                	test   %eax,%eax
80108468:	75 07                	jne    80108471 <uva2ka+0x36>
    return 0;
8010846a:	b8 00 00 00 00       	mov    $0x0,%eax
8010846f:	eb 22                	jmp    80108493 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
80108471:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108474:	8b 00                	mov    (%eax),%eax
80108476:	83 e0 04             	and    $0x4,%eax
80108479:	85 c0                	test   %eax,%eax
8010847b:	75 07                	jne    80108484 <uva2ka+0x49>
    return 0;
8010847d:	b8 00 00 00 00       	mov    $0x0,%eax
80108482:	eb 0f                	jmp    80108493 <uva2ka+0x58>
  return (char*)P2V(PTE_ADDR(*pte));
80108484:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108487:	8b 00                	mov    (%eax),%eax
80108489:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010848e:	05 00 00 00 80       	add    $0x80000000,%eax
}
80108493:	c9                   	leave  
80108494:	c3                   	ret    

80108495 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108495:	55                   	push   %ebp
80108496:	89 e5                	mov    %esp,%ebp
80108498:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
8010849b:	8b 45 10             	mov    0x10(%ebp),%eax
8010849e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801084a1:	e9 87 00 00 00       	jmp    8010852d <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
801084a6:	8b 45 0c             	mov    0xc(%ebp),%eax
801084a9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084ae:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801084b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084b4:	89 44 24 04          	mov    %eax,0x4(%esp)
801084b8:	8b 45 08             	mov    0x8(%ebp),%eax
801084bb:	89 04 24             	mov    %eax,(%esp)
801084be:	e8 78 ff ff ff       	call   8010843b <uva2ka>
801084c3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801084c6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801084ca:	75 07                	jne    801084d3 <copyout+0x3e>
      return -1;
801084cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801084d1:	eb 69                	jmp    8010853c <copyout+0xa7>
    n = PGSIZE - (va - va0);
801084d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801084d6:	8b 55 ec             	mov    -0x14(%ebp),%edx
801084d9:	29 c2                	sub    %eax,%edx
801084db:	89 d0                	mov    %edx,%eax
801084dd:	05 00 10 00 00       	add    $0x1000,%eax
801084e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801084e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084e8:	3b 45 14             	cmp    0x14(%ebp),%eax
801084eb:	76 06                	jbe    801084f3 <copyout+0x5e>
      n = len;
801084ed:	8b 45 14             	mov    0x14(%ebp),%eax
801084f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801084f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084f6:	8b 55 0c             	mov    0xc(%ebp),%edx
801084f9:	29 c2                	sub    %eax,%edx
801084fb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801084fe:	01 c2                	add    %eax,%edx
80108500:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108503:	89 44 24 08          	mov    %eax,0x8(%esp)
80108507:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010850a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010850e:	89 14 24             	mov    %edx,(%esp)
80108511:	e8 3d cd ff ff       	call   80105253 <memmove>
    len -= n;
80108516:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108519:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
8010851c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010851f:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108522:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108525:	05 00 10 00 00       	add    $0x1000,%eax
8010852a:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
8010852d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108531:	0f 85 6f ff ff ff    	jne    801084a6 <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80108537:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010853c:	c9                   	leave  
8010853d:	c3                   	ret    
