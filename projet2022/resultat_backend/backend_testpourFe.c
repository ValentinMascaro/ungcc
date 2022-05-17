extern void free(void *ptr);
extern void *malloc(int size);
void *allouer(void *p)
{
	void *_var1;
	void *_var2;
	void *_var3;
	if (p == 0) goto Lelse1;
	{
	_var1 = p + 4;
	_var2=malloc(4);
	*_var1 =_var2;
	_var3 = p + 4;
	return _var3;
	}
Lelse1:
	{
	p = malloc(4);
	return p;
	}
}
void *desallouer(void *p)
{
	void *q;
	void *_var4;
	_var4 = p + 4;
	q = _var4;
	free(p);
	return q;
}
void *parcours(void *l, void *f)
{
	int i;
	void *p;
	void *tete;
	p = (*f)(l);
	tete = p;
	i = 0;
	goto Ltest2;
LBody2 :
	p = (*f)(p);
	i = i + 1;
Ltest2:
	if(i < 100) goto LBody2;
	return tete;
}
void main()
{
	void *tete;
	int _var5;
	int _var6;
	_var5 = &allouer;
	tete = parcours(0, _var5);
	_var6 = &desallouer;
	parcours(tete, _var6);
	return 1;
}
