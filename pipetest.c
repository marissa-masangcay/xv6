#include "types.h" 
#include "stat.h" 
#include "user.h" 


/*--------------------------------------------------------
Function:     writeFile
Purpose:      Writes to the file input
*/
void writeFile(int fd) {

    int charCount = 0;
    char c;

   while((n = write(fd, &c, 1)) > 0);
    {
        charCount++;
    }

    printf("Bytes written = %d\n", charCount);

    return;
}
/*--------------------------------------------------------
Function:     readFile
Purpose:      Reads through the file until the end of the 
              file is reached
*/
void readFile(int fd) {

    int charCount = 0;
    char c;

   while((n = read(fd, &c, 1)) > 0);
    {
        charCount++;
    }

    printf("Bytes read = %d\n", charCount);

    return;
}

/*--------------------------------------------------------*/

int main(int argc, char **argv) 
{ 

	printf(1, "in pipetest.c\n");

	int fd[2];
	pipe(fd);

	char *read_file;
	char *write_file;

	read_file = "read.txt";
    write_file = "write.txt";

    //get file descriptor to read file from
	fd[0] = open(read_file, O_RDONLY);
	if (fd[0] < 0)
	{
		printf(1,"Cannot open %s\n", read_file);
	}
	else{
		readFile(fd[0]);
	}

    //get file descriptor to write file to
	fd[1] = open(write_file, O_WRONLY|O_TRUNC|O_CREAT, 0644);
	if (fd[1] < 0)
	{
		printf(1,"Cannot open %s\n", write_file);
	}
	else{
		writeFile(fd[1]);
	}


	close(fd[0]);
	close(fd[1]);

  // int test;
  // test = pipe_count(1);
  // printf(1, "Pipe_count= %d\n", test);

	exit(); 
}
