#include <string.h>
#include <iostream>
#include <vector>
#include <map>
#include <string>

using namespace std;

/* symbol table entry */
enum dataType { INT_, REAL_, CHAR_, STARING_, BOOLEAN_ };

struct entry {
	enum dataType dType;
	
	union V
	{
		int iVal;
		double rVal;
		char cVal;
		string* sVal;
		bool bVal;
		V() {}
		V(int i) { iVal = i; }
		V(double d) { rVal = d; }
		V(char c) { cVal = c; }
		V(string* s) { sVal = s; }
		V(bool b) { bVal = b; }
		~V() {}
	}val;
	
	entry() {}
	entry(const dataType& t,const union V& v);
	entry& operator= (entry& e);
};


struct table {
	map <string, entry> entry_;
	int lookup(const string& str);
	int insert(const string& str, const dataType& dType, const union entry::V& val);
	void dump();
};