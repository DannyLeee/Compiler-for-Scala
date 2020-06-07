#include "symbolTable.h"

// entry::entry(const entry& e) {
// 	dType = e.dType;
// 	isConst = e.isConst;
// 	switch (dType)
// 	{
// 	case INT_:
// 		val.iVal = e.val.iVal;
// 		break;
// 	case REAL_:
// 		val.rVal = e.val.rVal;
// 		break;
// 	case CHAR_:
// 		val.cVal = e.val.cVal;
// 		break;
// 	case STR_:
// 		val.sVal = e.val.sVal;
// 		break;
// 	case BOOLEAN_:
// 		val.bVal = e.val.bVal;
// 		break;
// 	default:
// 		val.iVal = 0;
// 		break;
// 	}
// 	cout << "debug: calling copy constructor" << endl;
// }

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

entry::entry(const dataType& t, string* name) : dType(t), isConst(false) {
	val.sVal = name;
}

entry& entry::operator=(const entry& e)
{
	cout << "debug: calling assign overload" << endl;
	cout << e.dType << endl;
	this->dType = e.dType;
	cout << "test1.5" << endl;
	val.iVal = e.val.iVal;
	
	val.rVal = e.val.rVal;
	val.cVal = e.val.cVal;
	val.sVal = e.val.sVal;
	val.bVal = e.val.bVal;
	cout << "test1.51" << endl;
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
	cout << "debug: calling operator minus" << endl;
	cout << "type: " << this->dType << " " << this->val.iVal << " test1" << endl;
	if (this->dType == INT_)
	{
		entry temp(INT_, this->val.iVal, false);
		return temp;
	}
	else if (this->dType == REAL_)
		return entry(REAL_);
}

const int table::lookup(const string& name, const objType& objT) const {
	if (objT == OBJ)
	{
		// find duplicate object name
		if (this->object_.find(name) != this->object_.end())
			return 1;
	}
	else if (objT == FUNC)
	{
		// find duplicate function name
		if (this->func_.find(name) != this->func_.end())
			return 1;
	}
	else if (objT == VAR_)
	{
		// find duplicate variable name
		if (this->entry_.find(name) != this->entry_.end() || this->array_.find(name) != this->array_.end())
			return 1;
	}
	return -1;	// notfound
}

void table::insert(const string & name, const entry& e) {
	if (e.dType == OBJ_)
		this->object_[name] = e;
	else
		this->entry_[name] = e;
	return ;
}

void table::insert(const string& name, const dataType& t, const int& size) {
	vector<entry> v;
	for (int i = 0; i < size; i++)
		v.push_back(entry(t));
	this->array_[name] = v;
	return ;
}

void table::insert(const string& name, const dataType& t, const vector<entry>& list) {
	func_[name] = list;
	entry temp(t);
	func_[name].insert(func_[name].begin(), temp);
	return ;
}

void table::update(const string& name, const entry& e, const int& position, const bool& isArr) {
	if (isArr)
		this->array_[name][position] = e;
	else
		this->entry_[name] = e;
	return;
}

void table::dump() const {
	cout << "entry" << endl;
	cout << "name\ttype\tvalue" << endl;
	cout << "---------------------" << endl;
	for (auto it = this->entry_.begin(); it != this->entry_.end(); it++) {
		cout << it->first << "\t" << it->second.dType << "\t";
		switch (it->second.dType)
		{
		case INT_:
			cout << it->second.val.iVal;
			break;
		case REAL_:
			cout << it->second.val.rVal;
			break;
		case CHAR_:
			cout << it->second.val.cVal;
			break;
		case STR_:
			cout << *it->second.val.sVal;
			break;
		case BOOLEAN_:
			cout << it->second.val.bVal;
			break;
		default:
			break;
		}
		cout << endl;
	}
	cout << endl;
	
	cout << "array" << endl;
	cout << "name\ttype\tsize" << endl;
	cout << "--------------------" << endl;
	for (auto it = this->array_.begin(); it != this->array_.end(); it++) {
		cout << it->first << "\t" << it->second[0].dType << "\t" << it->second.size() << endl;
	}
	cout << endl;

	cout << "func " << this->func_.size() << endl;
	cout << "name\ttype\targSize" << endl;
	cout << "-----------------------" << endl;
	for (auto it = this->func_.begin(); it != this->func_.end(); it++) {
		// cout << it->first << "\t" << it->second[0].dType << "\t" << it->second.size() << endl;
		cout << it->first << endl;
	}
	cout << endl;

	cout << "object" << endl;
	cout << "name" <<endl;
	cout << "----" << endl;
	for (auto it = this->object_.begin(); it != this->object_.end(); it++) {
		cout << it->first << endl;
	}
	cout << endl;
	return;
}