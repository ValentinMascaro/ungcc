extern int printd(int i);
void *affiche(void *p)
{
	void *_var1;
	int _var2;
	if (p == 0) goto Lelse1;
	{
	_var1 = p + 0;
	_var2 = _var1;
	}
Lelse1:
	return p;
}
extern void *malloc(int size);
extern void free(void *ptr);
void *allouer(void *p)
{
	void *_var3;
	void *_var4;
	void *_var5;
	if (p == 0) goto Lelse2;
	{
	_var3 = p + 4;
	_var4=malloc(4);
	*_var3 =_var4;
	_var5 = p + 4;
	return _var5;
	}
Lelse2:
	{
	p = malloc(4);
	return p;
	}
}
void *desallouer(void *p)
{
	void *q;
	void *_var6;
	_var6 = p + 4;
	q = _var6;
	free(p);
	return q;
}
void *parcours(void *l, void *f)
{
	int i;
	void *p;
	void *tete;
	void *_var7;
	void *_var8;
	p = (*f)(l);
	tete = p;
	i = 0;
	goto Ltest4;
LBody4 :
	p = (*f)(p);
	if (p == 0) goto Lelse3;
	{
	_var7 = p + 0;
	_var8=i;
	*_var7 =_var8;
	}
Lelse3:
	i = i + 1;
Ltest4:
	if(i < 100) goto LBody4;
	return tete;
}
int main()
{
	void *tete;
	void *t;
	int _var9;
	int _var10;
	int _var11;
	_var9 = &allouer;
	tete = parcours(0, _var9);
	t = tete;
	_var10 = &affiche;
	parcours(t, _var10);
	_var11 = &desallouer;
	parcours(tete, _var11);
	return 0;
}
