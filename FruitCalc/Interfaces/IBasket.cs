using System.Collections.Generic;

interface IBasket {
    void Add(IItem item);

    void Clear();

    void Remove(IItem item);

    IEnumerable<IItem> Items();
}