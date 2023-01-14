String getNumberEnding(int num) {
  if (num >= 11 && num <= 19) {
    return "th";
  }
  switch (num % 10) {
    case 1:
      return "st";
    case 2:
      return "nd";
    case 3:
      return "rd";
    default:
      return "th";
  }
}
