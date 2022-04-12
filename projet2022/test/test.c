extern int printd(int i);

struct liste {
  int valeur; 
  struct liste *suivant;
};

struct pasliste {
  int valeur; 
  struct liste *suivant;
};

struct vraimentpasliste {
  int valeur; 
  struct liste *pasliste;
};

struct  {
  int valeur; 
  struct liste *suivant;
};



int *ptrInt(struct pasliste *a)
{
  int b;

  return b;
}

int *i;
int j;


struct vraimentpasliste *truc(int a,int j)
{
  return 0;
}

int main()
{
  struct vraimentpasliste *c;
  struct liste *d;
  c = truc(1,2)->pasliste->suivant;

}

/*TODO   c = truc(1,2)(1,2)(1,2); est juste ;_; ne devrai pas*/