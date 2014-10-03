/**
 * 时间选择canvas插件
 */
var DateSelect = (function () {
    function DateSelect(canvasId) {
        this.$el = $('#' + canvasId);
        this.weekTitleWidth = 50;
        this.cellSize = 0;
        this.borderWidth = 1;
        this.borderColor = '#c5cace';
        this.width = 0;
        this.height = 0;
        this.selectFrameColor = 'red';
        this.selectCellColor = '#55abff';
        this.selectedCellColor = '#3493ef';
        this.ctx = null;
        this.create();
    }

    DateSelect.prototype = {
        create: function () {
            this.selectedStartCell = {
                row: -1,
                column: -1
            };
            this.selectedEndCell = {
                row: -1,
                column: -1
            };
            this.isSelectedMode = false;
            this.initSize();
            this.initCanvas();
            this.initCell();
            this.bindEvent();
            this.draw();
        },
        initSize: function () {
            var cvsWidth = this.$el.parent().width();
            this.cellSize = (cvsWidth - this.weekTitleWidth - this.borderWidth * 2) / 24;
            this.$el[0].width = this.width = cvsWidth;
            this.$el[0].height = this.height = this.cellSize * 8 + 2;
        },
        initCanvas: function () {
            this.ctx = this.$el[0].getContext('2d');
        },
        drawSomeThing: function (drawMethod, strokeStyle, fillStyle) {
            this.ctx.save();
            this.ctx.translate(this.borderWidth, this.borderWidth);
            if (strokeStyle != null) this.ctx.strokeStyle = strokeStyle;
            if (fillStyle != null) this.ctx.fillStyle = fillStyle;
            drawMethod.apply(this);
            this.ctx.restore();
        },
        doSomeThing: function (method, startPostion, endPostion) {
            var col, end, row, start, _ref, _ref2, _results;
            var _this = this;
            start = {
                row: startPostion.row < endPostion.row ? startPostion.row : endPostion.row,
                col: startPostion.col < endPostion.col ? startPostion.col : endPostion.col
            };
            end = {
                row: startPostion.row >= endPostion.row ? startPostion.row : endPostion.row,
                col: startPostion.col >= endPostion.col ? startPostion.col : endPostion.col
            };
            _results = [];
            for (row = _ref = start.row, _ref2 = end.row; _ref <= _ref2 ? row <= _ref2 : row >= _ref2; _ref <= _ref2 ? row++ : row--) {
                _results.push((function () {
                    var _ref3, _ref4, _results2;
                    _results2 = [];
                    for (col = _ref3 = start.col, _ref4 = end.col; _ref3 <= _ref4 ? col <= _ref4 : col >= _ref4; _ref3 <= _ref4 ? col++ : col--) {
                        _results2.push(method.apply(_this, [row, col]));
                    }
                    return _results2;
                })());
            }
            return _results;
        },
        initCell: function () {
            var _this = this;
            this.cells = [];
            this.doSomeThing(function (row, col) {
                var type;
                if (row === 0 && col === 0) {
                    type = 'all';
                } else if (row === 0) {
                    type = 'date';
                } else if (col === 0) {
                    type = 'hour';
                } else {
                    type = 'normal';
                }
                if (col === 0) _this.cells[row] = [];
                _this.cells[row][col] = {
                    type: type,
                    idSelected: false,
                    rect: _this.getCellRect(row, col),
                    row: row,
                    col: col
                };
            }, {
                row: 0,
                col: 0
            }, {
                row: 7,
                col: 24
            });
        },
        draw: function () {
            this.ctx.clearRect(0, 0, this.width, this.height);
            this.drawSelectFrame();
            this.drawSelectedCells();
            this.drawCells();
            this.drawLabel();
        },
        bindEvent: function () {
            var end, _this, start;
            _this = this;
            start = {
                x: 0,
                y: 0
            };
            end = {
                x: 0,
                y: 0
            };
            this.$el.on('click', function (e) {
                var cell;
                cell = _this.getCell(e.offsetX, e.offsetY);
                if (cell == null) return;
                if (cell.row === 0 && cell.col === 0) return _this.selectedAll();
            });
            this.$el.on('mousedown', function (e) {
                var cell;
                cell = _this.getCell(e.offsetX, e.offsetY);
                if (cell == null) return;
                if (cell.row === 0 || cell.col === 0) return;
                _this.selectedStartCell = cell;
                _this.isSelectedMode = true;
                start.x = e.offsetX;
                start.y = e.offsetY;
            });
            this.$el.on('mouseup', function (e) {
                _this.isSelectedMode = false;
                _this.storeSelectedCells();
                _this.draw();
            });
            this.$el.on('mouseout', function (e) {
                _this.isSelectedMode = false;
                _this.storeSelectedCells();
                _this.draw();
            });
            this.$el.on('mousemove', function (e) {
                var cell;
                if (!_this.isSelectedMode) return;
                end.x = e.offsetX;
                end.y = e.offsetY;
                _this.selectFrameRect = {
                    x: (start.x < end.x ? start.x : end.x) - _this.borderWidth,
                    y: (start.y < end.y ? start.y : end.y) - _this.borderWidth,
                    width: Math.abs(start.x - end.x),
                    height: Math.abs(start.y - end.y)
                };
                cell = _this.getCell(e.offsetX, e.offsetY);
                if ((cell != null) && cell.row !== 0 && cell.col !== 0) {
                    _this.selectedEndCell = cell;
                }
                _this.draw();
            });
        },
        drawCells: function () {
            var _this = this;
            this.drawSomeThing(function () {
                var col, row;
                this.ctx.strokeStyle = this.borderColor;
                _this.ctx.beginPath();
                for (row = 0; row <= 8; row++) {
                    _this.drawHline(0, _this.cellSize * row, _this.width);
                }
                for (col = 0; col <= 25; col++) {
                    if (col === 0) {
                        _this.drawVline(0, 0, _this.height);
                    } else {
                        _this.drawVline(_this.cellSize * (col - 1) + _this.weekTitleWidth, 0, _this.height);
                    }
                }
                _this.ctx.stroke();
            });
        },
        drawLabel: function () {
            return this.drawSomeThing(function () {
                var days, i, j, _results;
                this.ctx.font = '14px Arial';
                this.ctx.fillStyle = '#000';
                for (i = 0; i <= 23; i++) {
                    this.ctx.fillText('' + i, this.weekTitleWidth + (this.cellSize * i) + (this.cellSize / 2) - 6, this.cellSize / 2 + 6);
                }
                days = ['全部', '日', '一', '二', '三', '四', '五', '六'];
                _results = [];
                _results.push(this.ctx.fillText(days[0], this.cellSize / 2 - 12, this.cellSize / 2 + 6));
                for (j = 1; j <= 7; j++) {
                    _results.push(this.ctx.fillText(days[j], this.cellSize / 2 - 6, this.cellSize / 2 + (this.cellSize * j) + 6));
                }
                return _results;
            });
        },
        storeSelectedCells: function () {
            var _ref, _ref2, _ref3, _ref4;
            this.doSomeThing(function (row, column) {
                var cell;
                cell = this.cells[row][column];
                cell.idSelected = !cell.idSelected;
            }, {
                row: (_ref = this.selectedStartCell) != null ? _ref.row : void 0,
                col: (_ref2 = this.selectedStartCell) != null ? _ref2.col : void 0
            }, {
                row: (_ref3 = this.selectedEndCell) != null ? _ref3.row : void 0,
                col: (_ref4 = this.selectedEndCell) != null ? _ref4.col : void 0
            });
            this.selectedStartCell = {
                row: -1,
                column: -1
            };
            this.selectedEndCell = {
                row: -1,
                column: -1
            };
        },
        selectedAll: function () {
            var cell, have_selected, rows, _i, _j, _k, _l, _len, _len2, _len3, _len4, _len5, _len6, _m, _n, _ref, _ref2, _ref3;
            have_selected = false;
            _ref = this.cells;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                rows = _ref[_i];
                for (_j = 0, _len2 = rows.length; _j < _len2; _j++) {
                    cell = rows[_j];
                    if (cell.idSelected === true) {
                        have_selected = true;
                        break;
                    }
                }
            }
            if (have_selected) {
                _ref2 = this.cells;
                for (_k = 0, _len3 = _ref2.length; _k < _len3; _k++) {
                    rows = _ref2[_k];
                    for (_l = 0, _len4 = rows.length; _l < _len4; _l++) {
                        cell = rows[_l];
                        cell.idSelected = false;
                    }
                }
            } else {
                _ref3 = this.cells;
                for (_m = 0, _len5 = _ref3.length; _m < _len5; _m++) {
                    rows = _ref3[_m];
                    for (_n = 0, _len6 = rows.length; _n < _len6; _n++) {
                        cell = rows[_n];
                        if (cell.type === 'normal') cell.idSelected = true;
                    }
                }
            }
            this.draw();
        },
        drawSelectedCells: function () {
            var _ref, _ref2, _ref3, _ref4;
            this.doSomeThing(function (row, column) {
                var cell;
                cell = this.cells[row][column];
                if (!cell.idSelected) return;
                this.drawSomeThing(function () {
                    this.ctx.fillStyle = this.selectedCellColor;
                    this.ctx.fillRect(cell.rect.x, cell.rect.y, cell.rect.width, cell.rect.height);
                });
            }, {
                row: 1,
                col: 1
            }, {
                row: 7,
                col: 24
            });
            this.doSomeThing(function (row, column) {
                var cell;
                cell = this.cells[row][column];
                this.drawSomeThing(function () {
                    this.ctx.fillStyle = this.selectCellColor;
                    this.ctx.fillRect(cell.rect.x, cell.rect.y, cell.rect.width, cell.rect.height);
                });
            }, {
                row: (_ref = this.selectedStartCell) != null ? _ref.row : void 0,
                col: (_ref2 = this.selectedStartCell) != null ? _ref2.col : void 0
            }, {
                row: (_ref3 = this.selectedEndCell) != null ? _ref3.row : void 0,
                col: (_ref4 = this.selectedEndCell) != null ? _ref4.col : void 0
            });
        },
        drawSelectFrame: function () {
            this.drawSomeThing(function () {
                if (!this.isSelectedMode) return;
                this.ctx.strokeRect(this.selectFrameRect.x, this.selectFrameRect.y, this.selectFrameRect.width, this.selectFrameRect.height);
            }, this.selectFrameColor);
        },
        drawHline: function (x, y, width) {
            this.ctx.moveTo(x, y);
            this.ctx.lineTo(x + width, y);
        },
        drawVline: function (x, y, height) {
            this.ctx.moveTo(x, y);
            this.ctx.lineTo(x, y + height);
        },
        isPointerInRect: function (x, y, rect) {
            if (x >= rect.x && x <= rect.x + rect.width && y >= rect.y && y <= rect.y + rect.height) {
                return true;
            }
            return false;
        },
        getCell: function (x, y) {
            var cell, rows, _i, _j, _len, _len2, _ref;
            _ref = this.cells;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                rows = _ref[_i];
                for (_j = 0, _len2 = rows.length; _j < _len2; _j++) {
                    cell = rows[_j];
                    if (this.isPointerInRect(x - this.borderWidth, y - this.borderWidth, cell.rect)) {
                        return cell;
                    }
                }
            }
            return null;
        },
        getCellRect: function (row, col) {
            if (col === 0) {
                return {
                    x: 0,
                    y: row * this.cellSize,
                    width: this.weekTitleWidth,
                    height: this.cellSize
                };
            } else {
                return {
                    x: (col - 1) * this.cellSize + this.weekTitleWidth,
                    y: row * this.cellSize,
                    width: this.cellSize,
                    height: this.cellSize
                };
            }
        },
        getSelectedCells: function () {
            var cell, lastOne, lastOneCol, lastOneRow, result, rows, _i, _j, _lastOne, _len, _len2, _ref;
            result = [];
            lastOne = null;
            _ref = this.cells;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                rows = _ref[_i];
                for (_j = 0, _len2 = rows.length; _j < _len2; _j++) {
                    cell = rows[_j];
                    if (cell.idSelected === true) {
                        if (result.length > 0) {
                            _lastOne = lastOne.split(':');
                            lastOneRow = parseInt(_lastOne[0]);
                            lastOneCol = parseInt(_lastOne[1]);
                            if ((((cell.row - 1) * 24 + (cell.col - 1)) - (lastOneRow * 24 + lastOneCol)) === 1) {
                                result[result.length - 1].end = (cell.row - 1) + ':' + (cell.col - 1);
                            } else {
                                if (cell.idSelected === true) {
                                    result.push({
                                        start: (cell.row - 1) + ':' + (cell.col - 1),
                                        end: (cell.row - 1) + ':' + (cell.col - 1)
                                    });
                                }
                            }
                        }
                        if (result.length < 1) {
                            result.push({
                                start: (cell.row - 1) + ':' + (cell.col - 1),
                                end: (cell.row - 1) + ':' + (cell.col - 1)
                            });
                        }
                        lastOne = (cell.row - 1) + ':' + (cell.col - 1);
                    }
                }
            }
            return result;
        },
        setSelectedCells: function (data) {
            var timeScope, _i, _len;
            for (_i = 0, _len = data.length; _i < _len; _i++) {
                timeScope = data[_i];
                this.changeSelectedCell(timeScope.start, timeScope.end);
            }
            this.draw();
        },
        clearDate: function () {
            var cell, rows, _i, _j, _len, _len2, _ref;
            _ref = this.cells;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                rows = _ref[_i];
                for (_j = 0, _len2 = rows.length; _j < _len2; _j++) {
                    cell = rows[_j];
                    cell.idSelected = false;
                }
            }
            this.draw();
        },
        changeSelectedCell: function (start, end) {
            var cell, col, endScope, row, startScope, _results;
            startScope = start.row * 24 + start.col;
            endScope = end.row * 24 + end.col;
            _results = [];
            for (cell = startScope; startScope <= endScope ? cell <= endScope : cell >= endScope; startScope <= endScope ? cell++ : cell--) {
                row = parseInt(cell / 24);
                col = cell % 24;
                _results.push(this.settingSelected(row, col, true));
            }
            return _results;
        },
        settingSelected: function (row, col, idSelected) {
            this.cells[row + 1][col + 1].idSelected = idSelected;
        }
    };

    return DateSelect;
}());