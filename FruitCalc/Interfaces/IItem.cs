namespace SM.Interfaces
{
    public interface IItem
    {
        int Count { get; set; }

        decimal Cost { get; set; }

        float? Discount { get; set; }

        string Name { get; }
    }
}