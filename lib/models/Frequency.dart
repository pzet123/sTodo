enum Frequency {
  completeOnce,
  everyday,
  everyNDays
}

Frequency getFrequencyFromString(String freqString){
  for (Frequency freq in Frequency.values){
    if(freq.toString() == freqString){
      return freq;
    }
  }
  return Frequency.completeOnce;
}