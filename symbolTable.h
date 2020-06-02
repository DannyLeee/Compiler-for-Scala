#include <string.h>
#include <iostream>
#include <vector>
#include <map>
#include <string>

using namespace std;

/* symbol table entry */
enum dataType { INT_, REAL_, CHAR_, STR_, BOOLEAN_, NAME_ };

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
	bool isConst;
	
	entry() {}
	entry(const dataType& t, const union V& v, const bool &isCon);
	entry(const dataType& t);
	entry& operator= (const entry& e);
	entry operator+ (const entry& e);
	entry operator- (const entry& e);
	entry operator* (const entry& e);
	entry operator/ (const entry& e);
	entry operator% (const entry& e);
	entry operator< (const entry& e);
	entry operator<= (const entry& e);
	entry operator>= (const entry& e);
	entry operator> (const entry& e);
	entry operator== (const entry& e);
	entry operator!= (const entry& e);
	entry operator&& (const entry& e);
	entry operator|| (const entry& e);
	entry operator!();
	entry operator- ();
};


struct table {
	map <string, entry> entry_;
	int lookup(const string& str);
	int insert(const string& str, const dataType& dType, const union entry::V& val, const bool &isCon);
	int insert(const string& str, const entry& e);
	void dump();
};