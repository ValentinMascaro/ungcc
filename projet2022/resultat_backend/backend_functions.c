extern int printd(int i);
extern void *malloc(int i);
void *fact ;
int foo(int n)
{
	int _var1;
	int _var2;
	if (n > 1) goto Lelse1;
	{
	return 1;
	}
Lelse1:
	_var1 = n - 1;
	_var2 = (*fact)(_var1);
	return n * _var2;
}
int main()
{
	int _var3;
	fact = &foo;
	_var3 = (*fact)(10);
	printd(_var3);
	return 0;
}
