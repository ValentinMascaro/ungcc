struct lastruct {
  int a;
  int *b;
  int c;
  int *d;
  struct lastruct *e;

};

int *a;

int main()
{
  int a;
  int *b;
  struct lastruct *c;
  a  = -(&(c->e)->e->e->e->e->e->c);
  }

