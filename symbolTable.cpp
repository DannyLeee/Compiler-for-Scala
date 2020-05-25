#include "symbolTable.h"


table create() {
	table sTable;
	return sTable;
}

int lookup(const table &t, const string &str) {
	if (t.entry_.find(str) != t.entry_.end())
		return 1;
	return -1;
}

int insert(table &t, const string &str, const int &val) {
	
    if (lookup(t, str) == -1) {
        entry temp;
		temp.value = val;
		t.entry_[str] = temp;
        return 1;
    }
    return -1;
}

void dump(const table &t) {
	for (auto it = t.entry_.cbegin(); it != t.entry_.end(); it++) {
		cout << it->first << endl;
	}
	return ;
}