#include "symbolTable.h"


table create() {
	table sTable;
	return sTable;
}

int table::lookup(const string &str) {
	if (this->entry_.find(str) != this->entry_.end())
		return 1;
	return -1;
}

int table::insert(const string &str, const int &val) {
	if (this->lookup(str) == -1) {
        entry temp;
		temp.value = val;
		this->entry_[str] = temp;
        return 1;
    }
    return -1;
}

void table::dump() {
	for (auto it = this->entry_.cbegin(); it != this->entry_.end(); it++) {
		cout << it->first << endl;
	}
	return ;
}