#include "symbolTable.h"
using namespace std;

Entry* create() {
	entry* sTable = new entry();
	sTable->name = "";
	sTable->next = NULL;
	return sTable;
}

int lookup(Entry* entry, const char* str) {
	if (entry == NULL)
		return -1;
	for (int i = 0; entry != NULL; i++) {
		if (strcmp(entry->name, str) == 0)
			return i;
		entry = entry->next;
	}
	return -1;
}

int insert(Entry* entry, char* str) {
	if (entry == NULL)
		return -1;
	int i;
    if (lookup(entry, str) == -1) {
        for (i = 0; entry != NULL; i++) {
            if (entry->next == NULL)
                break;
            entry = entry->next;
        }
        Entry* new_entry = new Entry();
        entry->next = new_entry;
        entry->name = str;
        new_entry->name = "";
        new_entry->next = NULL;
        return i;
    }
    return -1;
}

int dump(Entry* entry) {
	if (entry == NULL)
		return -1;
	int i;
	for (i = 0; entry->next != NULL; i++) {
		cout << entry->name << endl;
		entry = entry->next;
	}
	return i;
}