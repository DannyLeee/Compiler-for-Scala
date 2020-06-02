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

entry entry::operator+(const entry& e) {
	if (this->dType == REAL_ && e.dType == REAL_)
		return entry(REAL_, this->val.rVal + e.val.rVal, false);
	else if (this->dType == REAL_ && e.dType == INT_)
		return entry(REAL_, this->val.rVal + e.val.iVal, false);
	else if (this->dType == INT_ && e.dType == REAL_)
		return entry(REAL_, this->val.iVal + e.val.rVal, false);
	else
		return entry(INT_, this->val.iVal + e.val.iVal, false);
}

entry entry::operator-(const entry& e) {
	if (this->dType == REAL_ && e.dType == REAL_)
		return entry(REAL_, this->val.rVal - e.val.rVal, false);
	else if (this->dType == REAL_ && e.dType == INT_)
		return entry(REAL_, this->val.rVal - e.val.iVal, false);
	else if (this->dType == INT_ && e.dType == REAL_)
		return entry(REAL_, this->val.iVal - e.val.rVal, false);
	else
		return entry(INT_, this->val.iVal - e.val.iVal, false);
}

entry entry::operator*(const entry& e) {
	if (this->dType == REAL_ && e.dType == REAL_)
		return entry(REAL_, this->val.rVal * e.val.rVal, false);
	else if (this->dType == REAL_ && e.dType == INT_)
		return entry(REAL_, this->val.rVal * e.val.iVal, false);
	else if (this->dType == INT_ && e.dType == REAL_)
		return entry(REAL_, this->val.iVal * e.val.rVal, false);
	else
		return entry(INT_, this->val.iVal * e.val.iVal, false);
}

entry entry::operator/(const entry& e) {
	if (this->dType == REAL_ && e.dType == REAL_)
		return entry(REAL_, this->val.rVal / e.val.rVal, false);
	else if (this->dType == REAL_ && e.dType == INT_)
		return entry(REAL_, this->val.rVal / e.val.iVal, false);
	else if (this->dType == INT_ && e.dType == REAL_)
		return entry(REAL_, this->val.iVal / e.val.rVal, false);
	else
		return entry(REAL_, this->val.iVal / e.val.iVal, false);
}

entry entry::operator%(const entry& e) {
	return entry(INT_, this->val.iVal % e.val.iVal, false);
}

entry entry::operator<(const entry& e) {
	if (this->dType == REAL_ && e.dType == REAL_)
		return entry(BOOLEAN_, this->val.rVal < e.val.rVal, false);
	else if (this->dType == REAL_ && e.dType == INT_)
		return entry(BOOLEAN_, this->val.rVal < e.val.iVal, false);
	else if (this->dType == INT_ && e.dType == REAL_)
		return entry(BOOLEAN_, this->val.iVal < e.val.rVal, false);
	else
		return entry(BOOLEAN_, this->val.iVal < e.val.iVal, false);
}

entry entry::operator<=(const entry& e) {
	if (this->dType == REAL_ && e.dType == REAL_)
		return entry(BOOLEAN_, this->val.rVal <= e.val.rVal, false);
	else if (this->dType == REAL_ && e.dType == INT_)
		return entry(BOOLEAN_, this->val.rVal <= e.val.iVal, false);
	else if (this->dType == INT_ && e.dType == REAL_)
		return entry(BOOLEAN_, this->val.iVal <= e.val.rVal, false);
	else
		return entry(BOOLEAN_, this->val.iVal <= e.val.iVal, false);
}

entry entry::operator>=(const entry& e) {
	if (this->dType == REAL_ && e.dType == REAL_)
		return entry(BOOLEAN_, this->val.rVal > e.val.rVal, false);
	else if (this->dType == REAL_ && e.dType == INT_)
		return entry(BOOLEAN_, this->val.rVal > e.val.iVal, false);
	else if (this->dType == INT_ && e.dType == REAL_)
		return entry(BOOLEAN_, this->val.iVal > e.val.rVal, false);
	else
		return entry(BOOLEAN_, this->val.iVal > e.val.iVal, false);
}

entry entry::operator>(const entry& e) {
	if (this->dType == REAL_ && e.dType == REAL_)
		return entry(BOOLEAN_, this->val.rVal > e.val.rVal, false);
	else if (this->dType == REAL_ && e.dType == INT_)
		return entry(BOOLEAN_, this->val.rVal > e.val.iVal, false);
	else if (this->dType == INT_ && e.dType == REAL_)
		return entry(BOOLEAN_, this->val.iVal > e.val.rVal, false);
	else
		return entry(BOOLEAN_, this->val.iVal > e.val.iVal, false);
}

entry entry::operator==(const entry& e) {
	if (this->dType == REAL_ && e.dType == REAL_)
		return entry(BOOLEAN_, this->val.rVal == e.val.rVal, false);
	else if (this->dType == REAL_ && e.dType == INT_)
		return entry(BOOLEAN_, this->val.rVal == e.val.iVal, false);
	else if (this->dType == INT_ && e.dType == REAL_)
		return entry(BOOLEAN_, this->val.iVal == e.val.rVal, false);
	else
		return entry(BOOLEAN_, this->val.iVal == e.val.iVal, false);
	
	switch (this->dType)
	{
	case CHAR_:
		return entry(BOOLEAN_, this->val.cVal == e.val.cVal, false);
		break;
	case STR_:
		return entry(BOOLEAN_, *(this->val.sVal) == *(e.val.sVal), false);
		break;
	case BOOLEAN_:
		return entry(BOOLEAN_, this->val.bVal == e.val.bVal, false);
		break;
	default:
		break;
	}
}

entry entry::operator!=(const entry& e) {
	if (this->dType == REAL_ && e.dType == REAL_)
		return entry(BOOLEAN_, this->val.rVal != e.val.rVal, false);
	else if (this->dType == REAL_ && e.dType == INT_)
		return entry(BOOLEAN_, this->val.rVal != e.val.iVal, false);
	else if (this->dType == INT_ && e.dType == REAL_)
		return entry(BOOLEAN_, this->val.iVal != e.val.rVal, false);
	else
		return entry(BOOLEAN_, this->val.iVal != e.val.iVal, false);
	
	switch (this->dType)
	{
	case CHAR_:
		return entry(BOOLEAN_, this->val.cVal != e.val.cVal, false);
		break;
	case STR_:
		return entry(BOOLEAN_, *(this->val.sVal) != *(e.val.sVal), false);
		break;
	case BOOLEAN_:
		return entry(BOOLEAN_, this->val.bVal != e.val.bVal, false);
		break;
	default:
		break;
	}
}

entry entry::operator&&(const entry& e) {
	return entry(BOOLEAN_, this->val.bVal && e.val.bVal, false);
}

entry entry::operator||(const entry& e) {
	return entry(BOOLEAN_, this->val.bVal || e.val.bVal, false);
}

entry entry::operator!() {
	return entry(BOOLEAN_, !(this->val.bVal), false);
}

entry entry::operator-() {
	if (this->dType == INT_)
		return entry(INT_, -this->val.iVal, false);
	else if (this->dType == REAL_)
		return entry(REAL_, -this->val.rVal, false);
}

int table::lookup(const string& str) {
	if (this->entry_.find(str) != this->entry_.end())
		return 1;
	return -1;
}

int table::insert(const string & str, const entry& e) {
	if (this->lookup(str) == -1) {
		this->entry_[str] = e;
		return 1;
	}
	return -1;
}

int table::insert(const string& str, const dataType& t, const int& size) {
	if (this->lookup(str) == -1) {
		vector<entry> v;
		for (int i = 0; i < size; i++)
			v.push_back(entry(t));
		this->array_[str] = v;
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