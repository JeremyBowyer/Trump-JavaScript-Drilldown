$(function () {
		
	$.getJSON('/json_trump_drilldown_states.json', function (state_data) {
		$.getJSON('/json_trump_drilldown_counties.json', function (county_data) {
			var data = Highcharts.geojson(Highcharts.maps['countries/us/us-all']),
				// Some responsiveness
				small = $('#drill_down').width() < 400;
			// Set drilldown pointers
			$.each(data, function (i) {
				this.drilldown = this.properties['hc-key'];
			});
			// Instanciate the map
			Highcharts.mapChart('drill_down', {
				chart: {
					zoomType: '',
					panning: false,
					events: {
						drilldown: function (e) {

							if (!e.seriesOptions) {
								var chart = this,
									mapKey = 'countries/us/' + e.point.drilldown + '-all',
									// Handle error, the timeout is cleared on success
									fail = setTimeout(function () {
										if (!Highcharts.maps[mapKey]) {
											chart.showLoading('<i class="icon-frown"></i> Failed loading ' + e.point.name);

											fail = setTimeout(function () {
												chart.hideLoading();
											}, 1000);
										}
									}, 3000);

								// Show the spinner
								chart.showLoading('<i class="icon-spinner icon-spin icon-3x"></i>'); // Font Awesome spinner
								chart.legend.options.y = 1000;
								// Load the drilldown map
								$.getScript('https://code.highcharts.com/mapdata/' + mapKey + '.js', function () {

									data = Highcharts.geojson(Highcharts.maps[mapKey]);
									
									// Hide loading and add series
									chart.hideLoading();
									clearTimeout(fail);
									chart.addSeriesAsDrilldown(e.point, {
										name: e.point.name,
										mapData: data,
										data: county_data,
										joinBy: ['hc-key', 'code'],
										dataLabels: {
											enabled: true,
											format: '{point.name}'
										}
									});
								});
							}


							this.setTitle(null, { text: e.point.name });
						},
						drillup: function () {
							this.setTitle(null, { text: 'USA' });
							this.legend.options.y = 0; //showing the legend by resetting its offset
						}
					}
				},
				
				tooltip: {
					formatter: function() {
						return '<b>' + this.point.name + '</b>' +
						'<br>Poll Spread: ' + this.point.Poll_Spread.toFixed(2) + '%' +
						'<br>Result Spread: ' +	this.point.Result_Spread.toFixed(2) + '%' +
						'<br>Relative Performance: ' + this.point.value.toFixed(2) + '%';
					}
				},
				
				title: {
					text: 'Trump Over/Under performance relative to polls'
				},

				subtitle: {
					text: 'USA',
					floating: true,
					align: 'right',
					y: 50,
					style: {
						fontSize: '16px'
					}
				},

				legend: small ? {} : {
					layout: 'vertical',
					align: 'right',
					verticalAlign: 'middle'
				},

				colorAxis: {
					stops: [
						[0, '#0000ff'],
						[0.5, '#ffffff'],
						[1, '#ff0000']
					],
					min: -10,
					max: 10
				},

				mapNavigation: {
					enabled: true,
					buttonOptions: {
						verticalAlign: 'bottom'
					}
				},

				plotOptions: {
					map: {
						states: {
							hover: {
								color: '#63666b'
							}
						}
					}
				},

				series: [{
					data: state_data,
					mapData: data,
					joinBy: ['hc-key', 'code'],
					name: 'USA',
					dataLabels: {
						enabled: true,
						format: '{point.properties.postal-code}'
					}
				}],

				drilldown: {
					activeDataLabelStyle: {
						color: '#FFFFFF',
						textDecoration: 'none',
						textOutline: '1px #000000'
					},
					drillUpButton: {
						relativeTo: 'spacingBox',
						position: {
							x: 0,
							y: 60
						}
					}
				}
			});
		});
	});
});