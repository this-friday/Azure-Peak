export const formatTime = (deciseconds: number): string => {
  const totalSeconds = Math.floor(deciseconds / 10);
  const minutes = Math.floor(totalSeconds / 60);
  const seconds = totalSeconds % 60;
  return `${minutes}:${seconds.toString().padStart(2, '0')}`;
};
 
export const stageLabel = (stage: number): string => {
  if (stage === 1) return 'Warband Selection';
  if (stage === 2) return 'Casus Belli';
  if (stage === 3) return 'Class Selection';
  return 'Go Forth';
};
