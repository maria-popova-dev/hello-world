String shortenNumber(int number){
  if(number >=1000000){
    return '${(number/1000000).floor()}M';
  } else if (number >=1000) {
  return '${(number/1000).floor()}K';
  } else {
    return number.toString();
  }
}