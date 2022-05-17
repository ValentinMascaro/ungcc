extern int printd(int i);
int main()
{
	int i;
	int _var1;
	int _var2;
	i = 0;
	goto Ltest1;
LBody1 :
	printd(i);
	i = i + 2;
Ltest1:
	if(i >= 10) goto LBody1;
	i = -10;
	goto Ltest1;
LBody1 :
	i = i + 1;
	_var1 = i;
Ltest1:
	if(i <= 10) goto LBody1;
	i = 0;
	_var2 = -20;
	goto Ltest1;
LBody1 :
	printd(i);
	i = i - 1;
Ltest1:
	if(i < _var2) goto LBody1;
	return 0;
}
