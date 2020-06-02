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
	entry operator-();
};

struct table {
	map <string, entry> entry_;
	map <string, vector<entry>> array_;
	int lookup(const string& name);
	int insert(const string& name, const entry& e);
	int insert(const string& name, const dataType& t, const int& size);
	void update(const string& name, const entry& e, const int& position , const bool& isArr);
	void dump();
};