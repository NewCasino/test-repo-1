namespace Luxbook.MVC.Common
{
    using System;

    public class Enums
    {
        [Flags]
        public enum RaceType
        {
            Greyhounds = 1,
            Harness = 2,
            Races = 4
        }

        public enum BetType
        {
            Win,
            Place,
            Quinella,
            Exacta,
            Duet,
            Trifecta,
            First4,
            WinAndPlace
        }

        public enum RaceStatus
        {
            Open,
            Closed,
            Interim,
            Done,
            Protest,
            Skip,
            Abandoned,
            Final,
            Check
        }


    }
}