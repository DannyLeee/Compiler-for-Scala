#include "symbolTable.h"

entry::entry(const dataType& t, const union V& v, const bool &isCon) : dType(t), isConst(isCon) {
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
	case STR_:
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

entry::entry(const dataType& t) : dType(t), isConst(false) {
	switch (t)
	{
	case INT_:
		val.iVal = 0;
		break;
	case REAL_:
		val.rVal = 0.0;
		break;
	case CHAR_:
		val.cVal = '\0';
		break;
	case STR_:
		val.sVal = new string("");
		break;
	case BOOLEAN_:
		val.bVal = true;
		break;
	default:
		val.iVal = 0;
		break;
	}
}

entry& entry::operator=(const entry& e)
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

int table::insert(const string& str, const dataType& dType, const union entry::V& val,const bool &isCon) {
	if (this->lookup(str) == -1) {
		entry temp(dType, val, isCon);
		this->entry_[str] = temp;
		return 1;
	}
	return -1;
}

int table::insert(const string & str, const entry& e) {
	if (this->lookup(str) == -1) {
		this->entry_[str] = e;
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