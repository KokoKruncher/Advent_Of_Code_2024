function newNumber = turnDial(currentNumber, nClicks)
newNumber = currentNumber + nClicks;

if newNumber < 0
    newNumber = 100 - rem(newNumber, 100);
elseif newNumber > 99
    newNumber = rem(newNumber, 100);
end
end