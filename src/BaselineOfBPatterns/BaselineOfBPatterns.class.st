Class {
	#name : 'BaselineOfBPatterns',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfBPatterns',
	#package : 'BaselineOfBPatterns'
}

{ #category : 'baselines' }
BaselineOfBPatterns >> baseline: spec [
	<baseline>

"
			package: #'BPatterns-Calypso' with: [ spec requires: #('BPatterns') ];
			package: #'BPatterns-Calypso-Tests' with: [ spec requires: #('BPatterns-Calypso') ];
			package: #'BPatterns-RewritePreview' with: [ spec requires: #('BPatterns') ];
			package: #'BPatterns-RewritePreview-Tests' with: [ spec requires: #('BPatterns-RewritePreview') ];

			group: 'Tools' with: #('BPatterns-Calypso' 'BPatterns-RewritePreview' 'BPatterns-Deprecation');
			group: 'ToolsTests' with: #('BPatterns-Calypso-Tests' 'BPatterns-RewritePreview-Tests' 'BPatterns-Deprecation-Tests');
			group: 'default' with: #('Core' 'CoreTests' 'Tools' 'ToolsTests'). 

"
	spec for: #'common' do: [
		spec 
			package: #'BPatterns';
			package: #'BPatterns-Tests' with: [ spec requires: #('BPatterns') ];
			package: #'BPatterns-Deprecation' with: [ spec requires: #('BPatterns') ];
			package: #'BPatterns-Deprecation-Tests' with: [ spec requires: #('BPatterns-Deprecation') ];
			package: #'BPatterns-GtViews' with: [ spec requires: #('BPatterns') ].
		spec 
			group: 'Core' with: #('BPatterns' );
			group: 'CoreTests' with: #('BPatterns-Tests');
			group: 'Tools' with: #('BPatterns-Deprecation');
			group: 'ToolsTests' with: #('BPatterns-Deprecation-Tests');
			group: 'GTViews' with: #('BPatterns-GtViews');
			group: 'default' with: #('Core' 'CoreTests' 'Tools' 'ToolsTests' 'GTViews'). 
		].
]
