namespace Luxbook.MVC.Models
{
    public class MaxExposureParameter
    {
        public MaxExposureParameter() { }
        public MaxExposureParameter(string name, string param1, string param2, decimal? value)
        {
            Name = name;
            Param1 = param1;
            Param2 = param2;
            Value = value;
        }

        public string Name { get; set; }
        public string Param1 { get; set; }
        public string Param2 { get; set; }
        public decimal? Value { get; set; }
    }
}