extern int printd(int i);
void main()
{
	int i;
	i = 0;
	goto Ltest1;
LBody1 :
	printd(i);
	i = i + 1;
Ltest1:
	if(i < 1000) goto LBody1;
	return 0;
}
