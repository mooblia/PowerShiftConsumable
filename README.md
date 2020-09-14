# PowerShiftConsumable

A WoW Classic AddOn to assist with druids consuming quickly in forms, and shifting back in.

## The problem

Powershifting consumables in classic is trivial, as we can make macros like so.

```
/cancelform
/use Major Healing Potion
/cast Dire Bear Form
```

However this is not nearly as flexible as you would like as you need to make a macro for each combination of consumable + form you might wanna shift into. And changing on the fly is a chore.

What I really wanted was to power charge some action buttons so that if it is pressed, we shift out, do whatever action is on that button and finally we shift back into whatever form we previously were in.

## The solution

Say you have a Major Healing Potion on `MultiBarBottomLeftButton1`, which you have bound to `SHIFT-1`.
The AddOn makes an `SecureActionButton` which contains one of 4 macros depending on what form you are in.
This button is bound to `SHIFT-1` overriding the set keybind.

1. If in bear form
    ```
    /cancelform
    /click MultiBarBottomLeftButton1
    /cast Dire Bear Form
    ```
2. If in cat form
    ```
    /cancelform
    /click MultiBarBottomLeftButton1
    /cast Cat Form
    ```
3. If in travel/aquatic form
    ```
    /cancelform
    /click MultiBarBottomLeftButton1
    /cast [noswimming] Travel Form; Aquatic Form;
    ```
4. If in caster/moonkin form
    ```
    /click MultiBarBottomLeftButton1
    ```

So hitting `SHIFT-1` will shift you out, pop the Major Healing Potion, and shift you back in if you have mana and are not affected by global cooldown.

Now you ran out of Major Healing Potions so you drag a Superior Healing Potion from your bags onto the button, and yes next time you hit `SHIFT-1` you will pop the superior one. So now you don't need to have dozens of macros anymore, you can just enable a few buttons and it just works.

## Limitations

The addon only works for keys bound under *MultiActionBar* in Key Bindings. So for example bartender4 users that use non-standard keybindings, will have to swap back to the standard bindings, but you can keep your bar replacements. This approach should be UI independent as long as the standard binds are used. I tested on Stock, ElvUI and Bartender4 and it works fine.

Clicking with the mouse on buttons does not call these macros, we only override the keybindings.

## Usage

- **/pow status** to list what keys of what bars are being overwritten.
- **/pow enable/disable barname** to set/remove override bindings for all buttons of given bar.
- **/pow enable/disable barname N_1 N_2 ...** to set/remove override bindings for the N_1 key, N_2 key etc.
- **barname** can be one of 
    - MultiBarBottomLeft
    - MultiBarBottomRight
    - MultiBarRight
    - MultiBarLeft
- **N** is a number from 1 to 12.

## Example

Say you wanted to modify the first 10 keys of the secondary right action bar. You could achieve this by doing:

```
/pow enable MultiBarLeft
/pow disable MultiBarLeft 11 12
```
