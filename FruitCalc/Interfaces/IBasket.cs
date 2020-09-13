using System.Collections.Generic;

namespace SM.Interfaces
{
    public interface IBasket
    {
        IEnumerable<IValidItem> Items { get; }

        void Add(IValidItem item);

        void Clear();
    }
}