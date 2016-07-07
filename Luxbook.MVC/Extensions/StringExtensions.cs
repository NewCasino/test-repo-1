namespace Luxbook.MVC.Extensions
{
    using System;
    using System.Globalization;

    public static class StringExtensions
    {
        public static string ToTitleCase(this string target)
        {
            return CultureInfo.CurrentCulture.TextInfo.ToTitleCase(target.ToLower());
        }

        public static bool IsSameIgnoreCase(this string source, string target)
        {
            return string.Compare(source, target, StringComparison.InvariantCultureIgnoreCase) == 0;
        }
    }
}