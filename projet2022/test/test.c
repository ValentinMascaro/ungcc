struct lastruct {
  int a;
  int *b;
  void c;
  void *d;
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

