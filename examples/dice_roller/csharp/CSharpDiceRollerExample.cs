using Godot;
using Godot.Collections;

public partial class CSharpDiceRollerExample : Control
{
    // These nodes are marked with "Unique Name in Owner" in the scene,
    // allowing us to get them with the % syntax.
    private SubViewportContainer _diceRollerControl;
    private Label _resultLabel;
    private Label _diceLabel;
    private Button _rollButton;
    private Button _quickRollButton;

    public override void _Ready()
    {
        // In C#, it's good practice to get node references in _Ready().
        _diceRollerControl = GetNode<SubViewportContainer>("%DiceRollerControl");
        _resultLabel = GetNode<Label>("%ResultLabel");
        _diceLabel = GetNode<Label>("%DiceLabel");
        _rollButton = GetNode<Button>("%RollButton");
        _quickRollButton = GetNode<Button>("%QuickRollButton");

        // Connect signals from the UI elements to our C# methods.
        _rollButton.Pressed += OnRollButtonPressed;
        _quickRollButton.Pressed += OnQuickRollButtonPressed;

        // Connect signals from the DiceRollerControl (which is a GDScript object).
        // We use StringName for signal names.
        _diceRollerControl.Connect(new StringName("roll_started"), Callable.From(OnDiceRollerControlRollStarted));
        _diceRollerControl.Connect(new StringName("roll_finished"), Callable.From<long>(OnDiceRollerControlRollFinished));

        _resultLabel.Text = "Ready to Roll";

        // The GDScript example registers a custom dice. If you have custom dice
        // defined in C#, you would register them here. For example:
        // MyCustomCSharpDice.Register();
        // For now, we'll use the standard dice provided by the addon.
    }

    private void OnRollButtonPressed()
    {
        // Call the 'roll' method on the GDScript node.
        _diceRollerControl.Call("roll");
    }

    private void OnQuickRollButtonPressed()
    {
        // Call the 'quick_roll' method on the GDScript node.
        _diceRollerControl.Call("quick_roll");
    }

    private void OnDiceRollerControlRollStarted()
    {
        _resultLabel.Text = "Rolling...";
        // Call 'per_dice_result' and convert the result to a string.
        Variant perDiceResult = _diceRollerControl.Call("per_dice_result");
        _diceLabel.Text = perDiceResult.ToString();
    }

    // The 'roll_finished' signal in GDScript passes an int. In C#, this is received as a long.
    private void OnDiceRollerControlRollFinished(long result)
    {
        _resultLabel.Text = $"Result: {result}";
        Variant perDiceResult = _diceRollerControl.Call("per_dice_result");
        _diceLabel.Text = perDiceResult.ToString();
    }
}