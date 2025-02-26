// Real-time clock script
function updateClock() {
    const clockElement = document.getElementById("dynamic-clock");
    if (clockElement) {
      const now = new Date();
      const timeString = now.toLocaleTimeString([], { 
        hour: '2-digit', 
        minute: '2-digit', 
        second: '2-digit' 
      });
      clockElement.textContent = timeString;
    }
  }
  
  // Update the clock every second
  setInterval(updateClock, 1000);