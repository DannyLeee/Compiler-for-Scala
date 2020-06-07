#include <string.h>
#include <iostream>
#include <vector>
#include <map>
#include <string>

using namespace std;

/* symbol table entry */
enum dataType { INT_, REAL_, CHAR_, STR_, BOOLEAN_, OBJ_, NTYPE };

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
	
	entry() {}	// for variable declaration (hasn't define type)
	// entry(const entry& e);	// copy constructor
	entry(const dataType& t, const union V& v, const bool &isCon); // for constant exp
	entry(const dataType& t);	// for variable declaration (has define type)
	entry(const dataType& t, string* name);	// for formal argument
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

/* symbol table */
enum objType { OBJ, FUNC, VAR_ };

struct table {
	map <string, entry> entry_;			// store normal variable
	map <string, vector<entry>> array_;	// store array variable
	map <string, vector<entry>> func_;	// store function info
	map <string, entry> object_;			// store object
	const int lookup(const string& name, const objType& objT) const;
	void insert(const string& name, const entry& e);	// for normal variable or ibject declaration
	void insert(const string& name, const dataType& t, const int& size);	// for array declaration
	void insert(const string& name, const dataType& t, const vector<entry>& list);	// for function declaration
	void update(const string& name, const entry& e, const int& position , const bool& isArr);
	void dump() const;
};