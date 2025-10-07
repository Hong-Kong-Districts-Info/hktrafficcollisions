// Collapsible Checkbox Group functionality
(function() {
  // Initialize the collapsible checkbox group
  window.initCollapsibleCheckboxGroup = function(inputId) {
    // Wait for DOM to be ready
    $(document).ready(function() {
      var btnSelector = "#" + inputId + "_btn";
      var collapsibleSelector = "#" + inputId + "_collapsible";
      var $btn = $(btnSelector);
      var $collapsible = $(collapsibleSelector);
      
      // Detect Bootstrap version and set appropriate attributes
      // Add both data attributes for backward compatibility
      $btn
        .attr("data-target", collapsibleSelector)
        .attr("data-bs-target", collapsibleSelector) // Bootstrap 4/5
        .attr("data-toggle", "collapse")
        .attr("data-bs-toggle", "collapse") // Bootstrap 4/5
        .css("margin-bottom", "11px")
        .css("font-size", "12px");
        
      // Initialize button state based on initial collapse state
      if ($collapsible.hasClass("show") || $collapsible.hasClass("in")) {
        $btn.html("<span class=\"fa fa-chevron-up\"></span> Hide");
      } else {
        $btn.html("<span class=\"fa fa-chevron-down\"></span> Show All");
      }
      
      // Force initialize Bootstrap collapse functionality
      // This ensures the collapse is properly initialized regardless of Bootstrap version
      var collapse;
      if (typeof bootstrap !== 'undefined' && typeof bootstrap.Collapse !== 'undefined') {
        // Bootstrap 5
        collapse = new bootstrap.Collapse(document.querySelector(collapsibleSelector), {
          toggle: false
        });
      }
      
      // Ensure transitions are properly animated
      function animateCollapse(show) {
        if (show) {
          // First make visible with 0 height
          $collapsible.css({
            'display': 'block',
            'height': '0',
            'opacity': '0',
            'overflow': 'hidden'
          });
          
          // Get the natural height
          var height = $collapsible.prop('scrollHeight');
          
          // Animate to full height and opacity
          $collapsible.css({
            'height': height + 'px',
            'opacity': '1'
          });
          
          // After animation completes, set to auto height
          setTimeout(function() {
            $collapsible.css({
              'height': 'auto',
              'overflow': 'visible'
            });
          }, 250);
          
          // Update button
          $btn.html("<span class=\"fa fa-chevron-up\"></span> Hide");
        } else {
          // Get current height
          var height = $collapsible.height();
          
          // Set to that explicit height
          $collapsible.css({
            'height': height + 'px',
            'overflow': 'hidden'
          });
          
          // Force a repaint
          $collapsible[0].offsetHeight;
          
          // Animate to 0
          $collapsible.css({
            'height': '0',
            'opacity': '0'
          });
          
          // After animation, hide completely
          setTimeout(function() {
            $collapsible.css('display', 'none');
          }, 250);
          
          // Update button
          $btn.html("<span class=\"fa fa-chevron-down\"></span> Show All");
        }
      }
      
      // Use these events to update button text
      // The button text change needs to happen during transition, not after
      $collapsible.on("hide.bs.collapse", function() {
        $btn.html("<span class=\"fa fa-chevron-down\"></span> Show All");
      });
      
      $collapsible.on("show.bs.collapse", function() {
        $btn.html("<span class=\"fa fa-chevron-up\"></span> Hide");
      });
      
      // Add click handler directly to the button for smoother transition
      $btn.on("click", function(e) {
        e.preventDefault();
        e.stopPropagation(); // Prevent event bubbling
        
        var isVisible = $collapsible.hasClass("show") || $collapsible.hasClass("in") || 
                        ($collapsible.css('display') !== 'none' && $collapsible.height() > 0);
        
        // Use our custom animation if we're in a newer browser that supports it well
        if (typeof window.requestAnimationFrame !== 'undefined') {
          animateCollapse(!isVisible);
        } else {
          // Otherwise use the built-in collapse functionality
          if (isVisible) {
            if (typeof collapse !== 'undefined') {
              collapse.hide();
            } else {
              $collapsible.collapse('hide');
            }
          } else {
            if (typeof collapse !== 'undefined') {
              collapse.show();
            } else {
              $collapsible.collapse('show');
            }
          }
        }
      });
      
      // Debug logging
      console.log("Initialized collapsible checkbox group: " + inputId);
    });
  };
  
  // Initialize all collapsible checkboxes when Shiny session is initialized
  $(document).on('shiny:sessioninitialized', function() {
    // Find all collapsible elements by looking for elements ending with "_collapsible"
    $('[id$="_collapsible"]').each(function() {
      var id = $(this).attr('id');
      var inputId = id.replace('_collapsible', '');
      
      // Reinitialize this collapsible
      window.initCollapsibleCheckboxGroup(inputId);
      console.log("Auto-initialized collapsible: " + inputId);
    });
  });
})(); 