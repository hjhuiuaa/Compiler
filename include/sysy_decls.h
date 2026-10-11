/* Declarations only: the course sylib.h also defines globals.
 * Avoid including its definitions in both program and runtime objects. */
int getint(void);
int getch(void);
float getfloat(void);
int getarray(int a[]);
int getfarray(float a[]);
void putint(int a);
void putch(int a);
void putfloat(float a);
void putarray(int n, int a[]);
void putfarray(int n, float a[]);
void _sysy_starttime(int line);
void _sysy_stoptime(int line);
#define starttime() _sysy_starttime(__LINE__)
#define stoptime() _sysy_stoptime(__LINE__)
