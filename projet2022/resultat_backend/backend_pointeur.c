extern int printd(int i);
extern void malloc(int i);
int main()
{
	void *i;
	void *j;
	int _var1;
	int _var2;
	int _var3;
	int _var4;
	void *_var5;
	int _var6;
	i = malloc(4);
	j = malloc(4);
	*i = 4;
	_var1 = *i;
	printd(_var1);
	*j = 6;
	_var2 = *j;
	printd(_var2);
	i = i + 1;
	_var3 = *j;
	_var4 = *i;
	_var5= _var3 + _var4;
	*j =_var5;
	_var6 = *j;
	printd(_var6);
	return 0;
}
