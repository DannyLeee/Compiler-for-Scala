#include <string.h>
#include <iostream>
#include <vector>
#include <map>
#include <string>

using namespace std;

/* symbol table entry */
struct entry {
	int value;
};

struct table {
    map <string, entry> entry_;
};

table create();
int lookup(const table &t, const string &str);
int insert(table &t, const string &str, const int &val);
void dump(const table &t);