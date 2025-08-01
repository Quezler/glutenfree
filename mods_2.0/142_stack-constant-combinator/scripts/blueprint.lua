return [[
{
  "blueprint": 
  {
    "icons": 
    [
      
      {
        "signal": 
        {
          "name": "arithmetic-combinator"
        },
        "index": 1
      },
      
      {
        "signal": 
        {
          "name": "decider-combinator"
        },
        "index": 2
      }
    ],
    "entities": 
    [
      
      {
        "entity_number": 1,
        "name": "arithmetic-combinator",
        "position": 
        {
          "x": 1.5,
          "y": -3
        },
        "control_behavior": 
        {
          "arithmetic_conditions": 
          {
            "first_signal": 
            {
              "type": "virtual",
              "name": "signal-each"
            },
            "second_signal": 
            {
              "type": "virtual",
              "name": "signal-each"
            },
            "operation": "*",
            "output_signal": 
            {
              "type": "virtual",
              "name": "signal-each"
            },
            "first_signal_networks": 
            {
              "red": true,
              "green": false
            },
            "second_signal_networks": 
            {
              "red": false,
              "green": true
            }
          }
        }
      },
      
      {
        "entity_number": 2,
        "name": "arithmetic-combinator",
        "position": 
        {
          "x": 0.5,
          "y": -3
        },
        "control_behavior": 
        {
          "arithmetic_conditions": 
          {
            "first_signal": 
            {
              "type": "virtual",
              "name": "signal-each"
            },
            "second_constant": -1,
            "operation": "*",
            "output_signal": 
            {
              "type": "virtual",
              "name": "signal-each"
            }
          }
        }
      },
      
      {
        "entity_number": 3,
        "name": "selector-combinator",
        "position": 
        {
          "x": 1.5,
          "y": -1
        },
        "control_behavior": 
        {
          "operation": "stack-size"
        }
      },
      
      {
        "entity_number": 4,
        "name": "decider-combinator",
        "position": 
        {
          "x": 0.5,
          "y": -1
        },
        "control_behavior": 
        {
          "decider_conditions": 
          {
            "conditions": 
            [
              
              {
                "first_signal": 
                {
                  "type": "virtual",
                  "name": "signal-each"
                },
                "second_signal": 
                {
                  "type": "virtual",
                  "name": "signal-each"
                },
                "comparator": "=",
                "first_signal_networks": 
                {
                  "red": true,
                  "green": false
                },
                "second_signal_networks": 
                {
                  "red": true,
                  "green": false
                }
              }
            ],
            "outputs": 
            [
              
              {
                "signal": 
                {
                  "type": "virtual",
                  "name": "signal-each"
                },
                "networks": 
                {
                  "red": false,
                  "green": true
                }
              }
            ]
          }
        }
      }
    ],
    "wires": 
    [
      
      [
        1,
        1,
        3,
        3
      ],
      
      [
        1,
        2,
        3,
        2
      ],
      
      [
        1,
        3,
        2,
        3
      ],
      
      [
        2,
        1,
        4,
        3
      ],
      
      [
        3,
        2,
        4,
        2
      ],
      
      [
        3,
        3,
        4,
        1
      ]
    ],
    "item": "blueprint",
    "version": 562949957353472
  }
}
]]
