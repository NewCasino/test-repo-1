namespace Luxbook.MVC.Infrastructure
{
    using System.Text.RegularExpressions;

    public class StringHelper
    {
        public virtual string SplitCamelCase(string input)
        {
            return Regex.Replace(input, "(?<=[a-z])([A-Z])", " $1", RegexOptions.Compiled).Trim();
        }
    }
}