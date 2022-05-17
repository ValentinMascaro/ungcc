int main()
{
	int a;
	int b;
	goto Ltest1;
LBody1 :
	a = 1;
Ltest1:
	if(a != 0) goto LBody1;
}
