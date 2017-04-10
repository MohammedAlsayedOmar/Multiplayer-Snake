# Multiplayer-Snake
A Snake game made in assembly on 8086 using serial port to communicate and send data. It features also a chatting capability and a level design.

### Prerequisites

* [Virtual Serial Port](https://www.eltima.com/products/vspdxp/)
* MASM/TASM
* [DOS Box](https://www.dosbox.com/)


### Installing

Download MASM/TASM and make sure they are located at somewhere accessible. I have placed mine in "C:\Tools".

![Tools](/Screenshots/tools.JPG)

After downloading and installing [Virtual Serial Port](https://www.eltima.com/products/vspdxp/), from its menu click on "Add pair" button and you must have both "COM1" and "COM2" added.

![Virtual Serial Port](/Screenshots/1_serial_port.JPG)

After installing [DOS Box](https://www.dosbox.com/), go to it's file location and find "dosbox-X.XX.conf" where X represent the version. Mine is 0.74. If you couldn't find it, double click on "DOSBox X.XX Options.bat". If you still can't find anything, try opening your start menu then type dosbox and choose "DOSBox X.XX Options"

Open the ".conf" file and scroll down till the bottom then go a little bit up till you find
```
serial1=dummy
```
then change it to
```
serial1=directserial realport:com1
```
Don't forget to save. Now you are good to go. Keep this file open because we will need it in running.

## Running the tests

Now that everything is in place. Let's start.

Open up DOSBox and enter the following commands. Remember that each time you start DOSBox you have to do this.
```
mount c c:\tools
c:
```
where "C:\tools" is the place that contains "MASM.exe" and "C" is the DOSBox drive you want to mount on.

![Mount](/Screenshots/2_mount.jpg)

To make sure that everything is working properly, look at the second window that popped out and make sure that there is a line saying:
```
Serial1: Opening com1
```
![COM](/Screenshots/5_check.JPG)

This picture says 2 but make sure yours say 1 for now.

Good! The following process now will be done once.

First of all, add all of the following files to the "Tools" folder or whatever folder that contain the "MASM" and "LINK":_ "main.asm", "chatf.asm", "host.asm", "map.asm", "snake1.asm"_. And from "MAPS" folder, add _"1.txt", "2.txt", "3.txt"_ to the same location mentioned above.

Inside DOSBox, enter the following commands
```
masm main.asm;
link main.obj;
```

![MASM](/Screenshots/3_masm.jpg)

![LINK](/Screenshots/4_link.JPG)

Well done. Everything is now setup to start.

After mounting, Run the main.exe file by typing **"main"** inside dosbox. 
```
main
```
hopefully you'll get and "Enter your name" screen. Now go to the ".conf" file as mentioned earlier to keep it open and change the
```
serial1=directserial realport:com1
```
to
```
serial1=directserial realport:com2
```
and start a new DOSBox by double clicking the icon. After mounting, run the **"main"** directly to get two screens beside each other.
Make sure that the other one is opening com2
```
Serial1: Opening com2
```

Perfect. Now type your name. The main screen won't appear unless both users press the **Enter** key after they enter their name.

![Run](/Screenshots/6_run.JPG)

Hopefully now you can see this:

![Main Menu](/Screenshots/7_main_menu.JPG)

As it states, each function key is associated with something. Let's try them all.

Press "F1" on one of the screens and hopefully you see this message:

![Chat Invitation](/Screenshots/8_chat_inv.JPG)

On the host screen
```
You sent a CHAT invitation
```
On the other screen
```
<NAME> sent you a CHAT invitation,To accept press F1, To reject press N
```

After accepting, you'll both be moved to the chatting screen.

![Chatting](/Screenshots/9_real_chat_1.JPG)

![Chatting2](/Screenshots/10_real_chat_2.JPG)

pressing **Escape** key close the chat for both screens.

Now let's test the actual game. Press **Escape** in the chat to go back to main menu, then send game invitation by pressing the **F2** key on the keyboard. You should see something like this:

![Game Invitation](/Screenshots/11_game_inv_1.JPG)

On the host screen
```
You sent a GAME invitation
```
On the other screen
```
<NAME> sent you a GAME invitation,To accept press F1, To reject press N
```

After accepting this time a new screen appear. The level select:

![Game Invitation2](/Screenshots/12_game_inv_2.JPG)

On the host screen
```
Select Map [1,2,3]: 
```
On the other screen
```
<NAME> is selecting a map
```

After successfully loading the map, you can test the snake movement on both the maps but make sure the screen is selected.
Arrow key to move. Collect the blue fruit and avoid the obstacles

![Gameplay](/Screenshots/13_game_1.JPG)

During gameplay, the snake who eats himself or hit an obstacle losses. The maximum score is 10 who reach it is a winner.

![Gameplay2](/Screenshots/14_game_2.JPG)

There is a very rare case where the two snakes head hit each other. This is considered draw and the difference is score doesn’t matter.

Pressing **Escape** key returns you to the main menu.

Now let's try the level design.

Press **F3** on one of the screens.

![Level Design](/Screenshots/15_lvl_design.JPG)

The controls are simple, **Arrow** keys to move around **P** key once to continuous draw obstacles, **P** key again to disable the obstacle, **D** key with the cursor over the obstacle to delete it, **S** key to save the map and finally **L** key to load a saved map.

You can play on a newly created map.


## Developers

* **[Mohammed Mahmoud](https://github.com/Musgi)**, **[Ahmad Mostafa](https://github.com/ahmad-mostafa1000)**, **Mostafa El-Mohandes**, **Islam Khaled** and **[Mohammed Omar](https://github.com/MohammedAlsayedOmar)**

## License
This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
