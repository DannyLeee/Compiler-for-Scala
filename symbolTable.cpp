#include "symbolTable.h"

entry::entry(const dataType& t, const union V& v) : dType(t) {
	switch (t)
	{
	case INT_:
		val.iVal = v.iVal;
		break;
	case REAL_:
		val.rVal = v.rVal;
		break;
	case CHAR_:
		val.cVal = v.cVal;
		break;
	case STARING_:
		val.sVal = v.sVal;
		break;
	case BOOLEAN_:
		val.bVal = v.bVal;
		break;
	default:
		val.iVal = 0;
		break;
	}
}

entry& entry::operator=(entry& e)
{
	dType = e.dType;
	val.iVal = e.val.iVal;
	val.rVal = e.val.rVal;
	val.cVal = e.val.cVal;
	val.sVal = e.val.sVal;
	val.bVal = e.val.bVal;

	return *this;
}

int table::lookup(const string& str) {
	if (this->entry_.find(str) != this->entry_.end())
		return 1;
	return -1;
}

int table::insert(const string& str, const dataType& dType, const union entry::V& val) {
	if (this->lookup(str) == -1) {
		entry temp(dType, val);
		this->entry_[str] = temp;
		return 1;
	}
	return -1;
}

void table::dump() {
	for (auto it = this->entry_.cbegin(); it != this->entry_.end(); it++) {
		cout << it->first << endl;
	}
	return;
}