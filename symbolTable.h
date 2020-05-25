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
    int lookup(const string &str);
    int insert(const string &str, const int &val);
    void dump();
};

table create();